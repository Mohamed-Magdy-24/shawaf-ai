package ws

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		// Enforce local/controlled origin or allow standard local dev
		return true
	},
}

// Client represents a connected WebSocket operator
type Client struct {
	hub      *Hub
	conn     *websocket.Conn
	send     chan []byte
	siteID   string
	userID   string
	joinedAt time.Time
}

// Ticket holds single-use temporary authorization for WebSocket connection
type Ticket struct {
	SiteID    string
	UserID    string
	ExpiresAt time.Time
}

// Hub manages active WebSocket connections with tenant isolation and single-use tickets
type Hub struct {
	mu           sync.RWMutex
	clients      map[*Client]bool
	siteClients  map[string]map[*Client]bool
	tickets      map[string]*Ticket
	ticketMu     sync.Mutex
	broadcastCh  chan *BroadcastMessage
	registerCh   chan *Client
	unregisterCh chan *Client
}

type BroadcastMessage struct {
	SiteID  string
	Payload []byte
}

// NewHub initializes a new WebSocket Hub
func NewHub() *Hub {
	return &Hub{
		clients:      make(map[*Client]bool),
		siteClients:  make(map[string]map[*Client]bool),
		tickets:      make(map[string]*Ticket),
		broadcastCh:  make(chan *BroadcastMessage, 256),
		registerCh:   make(chan *Client),
		unregisterCh: make(chan *Client),
	}
}

// CreateTicket issues a 30-second single-use ticket for a validated user session
func (h *Hub) CreateTicket(siteID, userID string) string {
	h.ticketMu.Lock()
	defer h.ticketMu.Unlock()

	ticketID := uuid.New().String()
	h.tickets[ticketID] = &Ticket{
		SiteID:    siteID,
		UserID:    userID,
		ExpiresAt: time.Now().Add(30 * time.Second),
	}
	return ticketID
}

// ConsumeTicket validates and immediately burns the single-use ticket
func (h *Hub) ConsumeTicket(ticketID string) (*Ticket, bool) {
	h.ticketMu.Lock()
	defer h.ticketMu.Unlock()

	ticket, exists := h.tickets[ticketID]
	if !exists {
		return nil, false
	}
	delete(h.tickets, ticketID) // Burn immediately

	if time.Now().After(ticket.ExpiresAt) {
		return nil, false
	}
	return ticket, true
}

// Run starts the WebSocket hub event loop
func (h *Hub) Run() {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case client := <-h.registerCh:
			h.mu.Lock()
			h.clients[client] = true
			if _, exists := h.siteClients[client.siteID]; !exists {
				h.siteClients[client.siteID] = make(map[*Client]bool)
			}
			h.siteClients[client.siteID][client] = true
			h.mu.Unlock()
			log.Printf("[WSHub] Client registered: site=%s user=%s (active=%d)", client.siteID, client.userID, len(h.clients))

		case client := <-h.unregisterCh:
			h.mu.Lock()
			if _, exists := h.clients[client]; exists {
				delete(h.clients, client)
				close(client.send)
				if siteMap, ok := h.siteClients[client.siteID]; ok {
					delete(siteMap, client)
					if len(siteMap) == 0 {
						delete(h.siteClients, client.siteID)
					}
				}
			}
			h.mu.Unlock()
			log.Printf("[WSHub] Client disconnected: site=%s user=%s", client.siteID, client.userID)

		case msg := <-h.broadcastCh:
			h.mu.RLock()
			targets := h.siteClients[msg.SiteID]
			for client := range targets {
				select {
				case client.send <- msg.Payload:
				default:
					close(client.send)
					delete(h.clients, client)
					delete(targets, client)
				}
			}
			h.mu.RUnlock()

		case <-ticker.C:
			// Cleanup expired tickets
			h.ticketMu.Lock()
			now := time.Now()
			for id, t := range h.tickets {
				if now.After(t.ExpiresAt) {
					delete(h.tickets, id)
				}
			}
			h.ticketMu.Unlock()
		}
	}
}

// Broadcast sends a message to all connected clients authorized for a specific site
func (h *Hub) Broadcast(siteID string, payload []byte) {
	h.broadcastCh <- &BroadcastMessage{
		SiteID:  siteID,
		Payload: payload,
	}
}

// HandleWS upgrades an incoming HTTP request to a WebSocket connection after validating ticket
func (h *Hub) HandleWS(w http.ResponseWriter, r *http.Request) {
	ticketID := r.URL.Query().Get("ticket")
	if ticketID == "" {
		http.Error(w, `{"error":"ticket parameter required"}`, http.StatusUnauthorized)
		return
	}

	ticket, valid := h.ConsumeTicket(ticketID)
	if !valid {
		http.Error(w, `{"error":"invalid or expired ticket"}`, http.StatusForbidden)
		return
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("[WSHub] Upgrade failed: %v", err)
		return
	}

	client := &Client{
		hub:      h,
		conn:     conn,
		send:     make(chan []byte, 128),
		siteID:   ticket.SiteID,
		userID:   ticket.UserID,
		joinedAt: time.Now(),
	}

	h.registerCh <- client

	// Start read/write pumps
	go client.writePump()
	go client.readPump()
}

func (c *Client) readPump() {
	defer func() {
		c.hub.unregisterCh <- c
		c.conn.Close()
	}()

	c.conn.SetReadLimit(4096)
	_ = c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	c.conn.SetPongHandler(func(string) error {
		_ = c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})

	for {
		_, _, err := c.conn.ReadMessage()
		if err != nil {
			break
		}
	}
}

func (c *Client) writePump() {
	ticker := time.NewTicker(25 * time.Second)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case msg, ok := <-c.send:
			_ = c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if !ok {
				_ = c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			_, _ = w.Write(msg)

			// Drain queued messages
			n := len(c.send)
			for i := 0; i < n; i++ {
				_, _ = w.Write([]byte{'\n'})
				_, _ = w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
				return
			}

		case <-ticker.C:
			_ = c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

// BroadcastEvent formats and broadcasts an event to the hub
func (h *Hub) BroadcastEvent(siteID string, event interface{}) error {
	bytes, err := json.Marshal(map[string]interface{}{
		"type":    "alert.new",
		"site_id": siteID,
		"data":    event,
	})
	if err != nil {
		return err
	}
	h.Broadcast(siteID, bytes)
	return nil
}
