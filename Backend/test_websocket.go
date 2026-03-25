package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/url"
	"os"
	"os/signal"
	"time"

	"github.com/gorilla/websocket"
)

type Message struct {
	Type      string                 `json:"type"`
	ChatID    string                 `json:"chatId,omitempty"`
	Message   map[string]interface{} `json:"message,omitempty"`
	UserID    string                 `json:"userId,omitempty"`
	IsTyping  bool                   `json:"isTyping,omitempty"`
	MessageID string                 `json:"messageId,omitempty"`
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: go run test_websocket.go <chat_id> <auth_token>")
		fmt.Println("Example: go run test_websocket.go d560f0a6-7eda-474e-bd43-a970c3792cfb YOUR_JWT_TOKEN")
		os.Exit(1)
	}

	chatID := os.Args[1]
	token := os.Args[2]

	// Build WebSocket URL
	u := url.URL{
		Scheme:   "ws",
		Host:     "localhost:8081",
		Path:     fmt.Sprintf("/api/v1/ws/chat/%s", chatID),
		RawQuery: fmt.Sprintf("token=%s", token),
	}

	log.Printf("🔌 Connecting to %s", u.String())

	// Connect to WebSocket
	c, _, err := websocket.DefaultDialer.Dial(u.String(), nil)
	if err != nil {
		log.Fatal("❌ Dial error:", err)
	}
	defer c.Close()

	log.Println("✅ WebSocket connected!")

	// Setup interrupt handler
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)

	// Channel for receiving messages
	done := make(chan struct{})

	// Read messages
	go func() {
		defer close(done)
		for {
			_, message, err := c.ReadMessage()
			if err != nil {
				log.Println("❌ Read error:", err)
				return
			}

			var msg Message
			if err := json.Unmarshal(message, &msg); err != nil {
				log.Printf("❌ Parse error: %v", err)
				log.Printf("📨 Raw message: %s", string(message))
				continue
			}

			switch msg.Type {
			case "pong":
				log.Println("💓 Heartbeat pong received")
			case "new_message":
				log.Printf("📬 New message received from user %s", msg.UserID)
				if msg.Message != nil {
					content, _ := msg.Message["content"].(string)
					log.Printf("   Content: %s", content)
				}
			case "typing":
				if msg.IsTyping {
					log.Printf("✍️  User %s is typing...", msg.UserID)
				} else {
					log.Printf("✋ User %s stopped typing", msg.UserID)
				}
			case "mark_read":
				log.Printf("👁️  Message %s marked as read by user %s", msg.MessageID, msg.UserID)
			default:
				log.Printf("📨 Received: %s", string(message))
			}
		}
	}()

	// Send heartbeat every 30 seconds
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	// Test typing indicator after 2 seconds
	time.AfterFunc(2*time.Second, func() {
		log.Println("📤 Sending typing indicator (true)...")
		msg := Message{Type: "typing", IsTyping: true}
		data, _ := json.Marshal(msg)
		if err := c.WriteMessage(websocket.TextMessage, data); err != nil {
			log.Printf("❌ Error sending typing: %v", err)
		}
	})

	// Stop typing after 5 seconds
	time.AfterFunc(5*time.Second, func() {
		log.Println("📤 Sending typing indicator (false)...")
		msg := Message{Type: "typing", IsTyping: false}
		data, _ := json.Marshal(msg)
		if err := c.WriteMessage(websocket.TextMessage, data); err != nil {
			log.Printf("❌ Error sending typing: %v", err)
		}
	})

	log.Println("✅ WebSocket test running...")
	log.Println("   - Listening for new messages")
	log.Println("   - Listening for typing indicators")
	log.Println("   - Sending heartbeat every 30s")
	log.Println("   - Press Ctrl+C to exit")

	for {
		select {
		case <-done:
			return
		case <-ticker.C:
			log.Println("💓 Sending heartbeat ping...")
			msg := Message{Type: "ping"}
			data, _ := json.Marshal(msg)
			if err := c.WriteMessage(websocket.TextMessage, data); err != nil {
				log.Println("❌ Write error:", err)
				return
			}
		case <-interrupt:
			log.Println("🛑 Interrupt received, closing connection...")
			err := c.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			if err != nil {
				log.Println("❌ Write close error:", err)
				return
			}
			select {
			case <-done:
			case <-time.After(time.Second):
			}
			return
		}
	}
}
