package postgres

import (
	"context"
	"log"
	"time"

	"github.com/lib/pq"
)

// FireAlertListener listens for real-time PostgreSQL NOTIFY events on 'outbox_fire'
type FireAlertListener struct {
	listener *pq.Listener
	onFire   func()
}

// NewFireAlertListener creates an asynchronous listener for immediate fire alert routing
func NewFireAlertListener(databaseURL string, onFire func()) *FireAlertListener {
	reportProblem := func(ev pq.ListenerEventType, err error) {
		if err != nil {
			log.Printf("[WARN] PostgreSQL notification listener event %v: %v", ev, err)
		}
	}

	listener := pq.NewListener(databaseURL, 10*time.Second, time.Minute, reportProblem)
	return &FireAlertListener{
		listener: listener,
		onFire:   onFire,
	}
}

// Start begins listening on the outbox_fire channel until context cancellation
func (l *FireAlertListener) Start(ctx context.Context) {
	if err := l.listener.Listen("outbox_fire"); err != nil {
		log.Printf("[ERROR] Failed to LISTEN on outbox_fire: %v", err)
		return
	}
	log.Println("[INFO] PostgreSQL LISTEN active on channel 'outbox_fire' (fast-path fire routing enabled)")

	go func() {
		defer l.listener.Close()
		for {
			select {
			case <-ctx.Done():
				return
			case n := <-l.listener.Notify:
				if n == nil {
					continue
				}
				log.Printf("[ALERT] Received fast-path PostgreSQL NOTIFY on channel '%s'", n.Channel)
				if l.onFire != nil {
					l.onFire()
				}
			case <-time.After(time.Minute):
				// Ping database to keep listener connection healthy
				go l.listener.Ping()
			}
		}
	}()
}
