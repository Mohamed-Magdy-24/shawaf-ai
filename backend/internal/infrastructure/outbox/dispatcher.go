package outbox

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/domain"
	"github.com/lib/pq"
)

type NotificationChannel interface {
	Name() string
	Send(ctx context.Context, item *domain.OutboxItem) error
}

type Dispatcher struct {
	db          *sql.DB
	channels    map[string]NotificationChannel
	mu          sync.RWMutex
	stopCh      chan struct{}
	fireNotify  chan string
	workerCount int
}

func NewDispatcher(db *sql.DB) *Dispatcher {
	return &Dispatcher{
		db:          db,
		channels:    make(map[string]NotificationChannel),
		stopCh:      make(chan struct{}),
		fireNotify:  make(chan string, 100),
		workerCount: 3,
	}
}

func (d *Dispatcher) RegisterChannel(channel NotificationChannel) {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.channels[channel.Name()] = channel
}

func (d *Dispatcher) Start(ctx context.Context, dsn string) {
	log.Printf("[OUTBOX] Starting Outbox Dispatcher (SKIP LOCKED + LISTEN/NOTIFY)...")

	// 1. Dedicated Fire listener routine
	go d.listenFireNotifications(ctx, dsn)

	// 2. Fire unthrottled worker
	go d.processFireLoop(ctx)

	// 3. Regular batch polling workers
	for i := 0; i < d.workerCount; i++ {
		go d.pollLoop(ctx, i)
	}
}

func (d *Dispatcher) Stop() {
	close(d.stopCh)
}

func (d *Dispatcher) listenFireNotifications(ctx context.Context, dsn string) {
	reportProblem := func(ev pq.ListenerEventType, err error) {
		if err != nil {
			log.Printf("[OUTBOX-FIRE] Listener event error: %v", err)
		}
	}
	listener := pq.NewListener(dsn, 5*time.Second, 30*time.Second, reportProblem)
	if err := listener.Listen("outbox_fire"); err != nil {
		log.Printf("[OUTBOX-FIRE] Failed to listen on channel outbox_fire: %v", err)
		return
	}
	defer listener.Close()

	for {
		select {
		case <-ctx.Done():
			return
		case <-d.stopCh:
			return
		case notification := <-listener.Notify:
			if notification != nil {
				select {
				case d.fireNotify <- notification.Extra:
				default:
				}
			}
		}
	}
}

func (d *Dispatcher) processFireLoop(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			return
		case <-d.stopCh:
			return
		case <-d.fireNotify:
			d.dispatchFireRows(ctx)
		}
	}
}

func (d *Dispatcher) dispatchFireRows(ctx context.Context) {
	tx, err := d.db.BeginTx(ctx, nil)
	if err != nil {
		return
	}
	defer tx.Rollback()

	query := `
		SELECT id, event_id, site_id, priority, destination_channel, payload_json, status, attempts
		FROM outbox
		WHERE priority = 'CRITICAL_FIRE' AND status = 'PENDING'
		ORDER BY id ASC
		FOR UPDATE SKIP LOCKED
		LIMIT 10`

	rows, err := tx.QueryContext(ctx, query)
	if err != nil {
		return
	}
	defer rows.Close()

	var items []*domain.OutboxItem
	for rows.Next() {
		var it domain.OutboxItem
		var p string
		if err := rows.Scan(&it.ID, &it.EventID, &it.SiteID, &it.Priority, &it.DestinationChannel, &p, &it.Status, &it.Attempts); err != nil {
			continue
		}
		it.PayloadJSON = p
		items = append(items, &it)
	}

	for _, item := range items {
		d.deliverItem(ctx, tx, item)
	}
	_ = tx.Commit()
}

func (d *Dispatcher) pollLoop(ctx context.Context, workerID int) {
	ticker := time.NewTicker(200 * time.Millisecond)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-d.stopCh:
			return
		case <-ticker.C:
			d.pollAndDispatch(ctx)
		}
	}
}

func (d *Dispatcher) pollAndDispatch(ctx context.Context) {
	tx, err := d.db.BeginTx(ctx, nil)
	if err != nil {
		return
	}
	defer tx.Rollback()

	// Poll batch with lease locking
	query := `
		SELECT id, event_id, site_id, priority, destination_channel, payload_json, status, attempts
		FROM outbox
		WHERE (status = 'PENDING' AND next_attempt_at <= NOW())
		   OR (status = 'PROCESSING' AND locked_until < NOW())
		ORDER BY CASE WHEN priority = 'CRITICAL_FIRE' THEN 0 WHEN priority = 'CRITICAL' THEN 1 ELSE 2 END, id ASC
		FOR UPDATE SKIP LOCKED
		LIMIT 20`

	rows, err := tx.QueryContext(ctx, query)
	if err != nil {
		return
	}
	defer rows.Close()

	var items []*domain.OutboxItem
	for rows.Next() {
		var it domain.OutboxItem
		var p string
		if err := rows.Scan(&it.ID, &it.EventID, &it.SiteID, &it.Priority, &it.DestinationChannel, &p, &it.Status, &it.Attempts); err != nil {
			continue
		}
		it.PayloadJSON = p
		items = append(items, &it)
	}

	for _, item := range items {
		d.deliverItem(ctx, tx, item)
	}
	_ = tx.Commit()
}

func (d *Dispatcher) deliverItem(ctx context.Context, tx *sql.Tx, item *domain.OutboxItem) {
	d.mu.RLock()
	channel, exists := d.channels[item.DestinationChannel]
	d.mu.RUnlock()

	var deliveryErr error
	if !exists {
		// Default to WebSocket if channel unconfigured
		channel, exists = d.channels["WEBSOCKET"]
	}

	if exists {
		deliveryErr = channel.Send(ctx, item)
	} else {
		deliveryErr = fmt.Errorf("channel %s unhandled", item.DestinationChannel)
	}

	if deliveryErr == nil {
		_, _ = tx.ExecContext(ctx, "UPDATE outbox SET status = 'SENT', locked_until = NULL WHERE id = $1", item.ID)
	} else {
		item.Attempts++
		if item.Attempts >= 5 {
			_, _ = tx.ExecContext(ctx, "UPDATE outbox SET status = 'FAILED', locked_until = NULL WHERE id = $1", item.ID)
			deadLetter := `
				INSERT INTO outbox_dead_letter (outbox_id, event_id, site_id, failure_reason, payload_json)
				VALUES ($1, $2, $3, $4, $5)`
			_, _ = tx.ExecContext(ctx, deadLetter, item.ID, item.EventID, item.SiteID, deliveryErr.Error(), item.PayloadJSON)
		} else {
			backoff := time.Duration(item.Attempts*item.Attempts) * time.Second
			next := time.Now().Add(backoff)
			_, _ = tx.ExecContext(ctx, "UPDATE outbox SET status = 'PENDING', attempts = $1, next_attempt_at = $2, locked_until = NULL WHERE id = $3",
				item.Attempts, next, item.ID)
		}
	}
}
