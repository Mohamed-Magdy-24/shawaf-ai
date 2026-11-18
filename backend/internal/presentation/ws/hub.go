package ws

import (
	"log"
	"sync"
)

// Client represents a connected client WebSocket subscriber
type Client struct {
	Hub    *Hub
	Conn   *Conn
	SiteID string
	UserID string
	send   chan []byte
}

// Hub maintains active tenant-scoped WebSocket client connections
// Implements application.OutboxBroadcaster interface
type Hub struct {
	mu         sync.RWMutex
	tenants    map[string]map[*Client]bool
	register   chan *Client
	unregister chan *Client
}

// NewHub creates a new tenant-aware WebSocket broadcast hub
func NewHub() *Hub {
	return &Hub{
		tenants:    make(map[string]map[*Client]bool),
		register:   make(chan *Client),
		unregister: make(chan *Client),
	}
}

// Run executes the hub registration loop
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			if _, exists := h.tenants[client.SiteID]; !exists {
				h.tenants[client.SiteID] = make(map[*Client]bool)
			}
			h.tenants[client.SiteID][client] = true
			h.mu.Unlock()
			log.Printf("[INFO] Client %s enrolled in WebSocket events for site %s (total in site: %d)",
				client.UserID, client.SiteID, len(h.tenants[client.SiteID]))

		case client := <-h.unregister:
			h.mu.Lock()
			if clients, exists := h.tenants[client.SiteID]; exists {
				if _, ok := clients[client]; ok {
					delete(clients, client)
					close(client.send)
					client.Conn.Close()
					if len(clients) == 0 {
						delete(h.tenants, client.SiteID)
					}
				}
			}
			h.mu.Unlock()
			log.Printf("[INFO] Client %s removed from site %s", client.UserID, client.SiteID)
		}
	}
}

// RegisterClient enrolls a newly authenticated connection
func (h *Hub) RegisterClient(conn *Conn, siteID, userID string) *Client {
	client := &Client{
		Hub:    h,
		Conn:   conn,
		SiteID: siteID,
		UserID: userID,
		send:   make(chan []byte, 128),
	}

	h.register <- client

	// Start pump goroutines
	go client.writePump()
	go client.readPump()

	return client
}

// Broadcast sends payload strictly to clients registered to siteID
// Enforces 100% site tenant isolation at the WebSocket delivery tier
func (h *Hub) Broadcast(siteID string, payload []byte) error {
	h.mu.RLock()
	defer h.mu.RUnlock()

	clients, exists := h.tenants[siteID]
	if !exists || len(clients) == 0 {
		return nil
	}

	for client := range clients {
		select {
		case client.send <- payload:
		default:
			// If buffer full, drop or let unregister handle it
			log.Printf("[WARN] Dropping message for slow client %s in site %s", client.UserID, siteID)
		}
	}

	return nil
}

func (c *Client) writePump() {
	defer func() {
		c.Hub.unregister <- c
	}()

	for msg := range c.send {
		if err := c.Conn.WriteTextMessage(msg); err != nil {
			return
		}
	}
}

func (c *Client) readPump() {
	defer func() {
		c.Hub.unregister <- c
	}()

	for {
		_, _, err := c.Conn.ReadMessage()
		if err != nil {
			break
		}
	}
}
