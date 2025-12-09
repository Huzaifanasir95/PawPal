package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"pawpal-backend/internal/repositories"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		// Allow all origins for now - in production, check origin properly
		return true
	},
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

type Client struct {
	conn   *websocket.Conn
	send   chan []byte
	chatID string
	userID uuid.UUID
	hub    *Hub
}

type Hub struct {
	clients    map[string]map[*Client]bool // chatID -> clients
	broadcast  chan *Message
	register   chan *Client
	unregister chan *Client
	mu         sync.RWMutex
}

type Message struct {
	Type      string                 `json:"type"`
	ChatID    string                 `json:"chatId,omitempty"`
	Message   map[string]interface{} `json:"message,omitempty"`
	UserID    string                 `json:"userId,omitempty"`
	IsTyping  bool                   `json:"isTyping,omitempty"`
	MessageID string                 `json:"messageId,omitempty"`
}

var chatHub *Hub

func init() {
	chatHub = &Hub{
		clients:    make(map[string]map[*Client]bool),
		broadcast:  make(chan *Message, 256),
		register:   make(chan *Client),
		unregister: make(chan *Client),
	}
	go chatHub.run()
}

func (h *Hub) run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			if h.clients[client.chatID] == nil {
				h.clients[client.chatID] = make(map[*Client]bool)
			}
			h.clients[client.chatID][client] = true
			h.mu.Unlock()
			log.Printf("Client registered for chat: %s (Total: %d)", client.chatID, len(h.clients[client.chatID]))

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.chatID][client]; ok {
				delete(h.clients[client.chatID], client)
				close(client.send)
				if len(h.clients[client.chatID]) == 0 {
					delete(h.clients, client.chatID)
				}
			}
			h.mu.Unlock()
			log.Printf("Client unregistered from chat: %s", client.chatID)

		case message := <-h.broadcast:
			h.mu.RLock()
			clients := h.clients[message.ChatID]
			h.mu.RUnlock()

			for client := range clients {
				// Don't send message back to sender
				if message.UserID != "" && client.userID.String() == message.UserID {
					continue
				}
				select {
				case client.send <- mustMarshal(message):
				default:
					h.mu.Lock()
					close(client.send)
					delete(h.clients[message.ChatID], client)
					h.mu.Unlock()
				}
			}
		}
	}
}

func (c *Client) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})

	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error: %v", err)
			}
			break
		}

		var msg Message
		if err := json.Unmarshal(message, &msg); err != nil {
			log.Printf("Error unmarshaling message: %v", err)
			continue
		}

		msg.ChatID = c.chatID
		msg.UserID = c.userID.String()

		// Handle different message types
		switch msg.Type {
		case "ping":
			// Respond with pong
			c.send <- mustMarshal(Message{Type: "pong"})
		case "typing":
			// Broadcast typing indicator
			c.hub.broadcast <- &msg
		case "mark_read":
			// Handle mark as read - broadcast to other users
			c.hub.broadcast <- &msg
		}
	}
}

func (c *Client) writePump() {
	ticker := time.NewTicker(30 * time.Second)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

type WebSocketHandler struct {
	messageRepo *repositories.MessageRepository
	chatRepo    *repositories.ChatRepository
}

func NewWebSocketHandler(messageRepo *repositories.MessageRepository, chatRepo *repositories.ChatRepository) *WebSocketHandler {
	return &WebSocketHandler{
		messageRepo: messageRepo,
		chatRepo:    chatRepo,
	}
}

func (h *WebSocketHandler) HandleWebSocket(c *gin.Context) {
	chatID := c.Param("chatId")
	if chatID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Chat ID required"})
		return
	}

	// Get user from middleware
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	uidStr, ok := userID.(string)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID"})
		return
	}

	uid, err := uuid.Parse(uidStr)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID format"})
		return
	}

	// Upgrade connection
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("Failed to upgrade connection: %v", err)
		return
	}

	client := &Client{
		conn:   conn,
		send:   make(chan []byte, 256),
		chatID: chatID,
		userID: uid,
		hub:    chatHub,
	}

	client.hub.register <- client

	// Start read and write pumps
	go client.writePump()
	go client.readPump()
}

// BroadcastNewMessage sends a new message to all clients in a chat
func BroadcastNewMessage(chatID string, message map[string]interface{}, senderID string) {
	chatHub.broadcast <- &Message{
		Type:    "new_message",
		ChatID:  chatID,
		Message: message,
		UserID:  senderID,
	}
}

func mustMarshal(v interface{}) []byte {
	data, err := json.Marshal(v)
	if err != nil {
		log.Printf("Error marshaling message: %v", err)
		return []byte("{}")
	}
	return data
}
