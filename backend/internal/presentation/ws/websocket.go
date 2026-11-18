package ws

import (
	"bufio"
	"crypto/sha1"
	"encoding/base64"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"sync"
	"time"
)

const (
	wsGUID          = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
	opText          = 0x1
	opClose         = 0x8
	opPing          = 0x9
	opPong          = 0xA
)

// Conn wraps a hijacked TCP connection for standard RFC 6455 WebSockets
type Conn struct {
	netConn net.Conn
	reader  *bufio.Reader
	writer  *bufio.Writer
	writeMu sync.Mutex
	closed  bool
}

// Upgrade upgrades an HTTP GET request to RFC 6455 WebSocket connection
func Upgrade(w http.ResponseWriter, r *http.Request) (*Conn, error) {
	if r.Method != http.MethodGet {
		return nil, errors.New("websocket handshake must be GET")
	}

	key := r.Header.Get("Sec-WebSocket-Key")
	if key == "" {
		return nil, errors.New("missing Sec-WebSocket-Key header")
	}

	hijacker, ok := w.(http.Hijacker)
	if !ok {
		return nil, errors.New("webserver does not support hijacking")
	}

	netConn, buf, err := hijacker.Hijack()
	if err != nil {
		return nil, fmt.Errorf("hijack failed: %w", err)
	}

	// Compute Sec-WebSocket-Accept
	h := sha1.New()
	h.Write([]byte(key + wsGUID))
	accept := base64.StdEncoding.EncodeToString(h.Sum(nil))

	// Write handshake response
	resp := fmt.Sprintf("HTTP/1.1 101 Switching Protocols\r\n"+
		"Upgrade: websocket\r\n"+
		"Connection: Upgrade\r\n"+
		"Sec-WebSocket-Accept: %s\r\n\r\n", accept)

	if _, err := buf.WriteString(resp); err != nil {
		netConn.Close()
		return nil, err
	}
	if err := buf.Flush(); err != nil {
		netConn.Close()
		return nil, err
	}

	return &Conn{
		netConn: netConn,
		reader:  buf.Reader,
		writer:  buf.Writer,
	}, nil
}

// WriteTextMessage sends an unmasked text frame to the client
func (c *Conn) WriteTextMessage(payload []byte) error {
	c.writeMu.Lock()
	defer c.writeMu.Unlock()

	if c.closed {
		return errors.New("connection closed")
	}

	length := len(payload)
	var header []byte

	// FIN=1, Opcode=1 (Text)
	b0 := byte(0x80 | opText)

	if length <= 125 {
		header = []byte{b0, byte(length)}
	} else if length <= 65535 {
		header = make([]byte, 4)
		header[0] = b0
		header[1] = 126
		binary.BigEndian.PutUint16(header[2:4], uint16(length))
	} else {
		header = make([]byte, 10)
		header[0] = b0
		header[1] = 127
		binary.BigEndian.PutUint64(header[2:10], uint64(length))
	}

	if _, err := c.writer.Write(header); err != nil {
		return err
	}
	if _, err := c.writer.Write(payload); err != nil {
		return err
	}
	return c.writer.Flush()
}

// ReadMessage reads the next frame from the client, unwrapping client masking
func (c *Conn) ReadMessage() (byte, []byte, error) {
	for {
		b0, err := c.reader.ReadByte()
		if err != nil {
			return 0, nil, err
		}

		opcode := b0 & 0x0F
		b1, err := c.reader.ReadByte()
		if err != nil {
			return 0, nil, err
		}

		isMasked := (b1 & 0x80) != 0
		payloadLen := int64(b1 & 0x7F)

		if payloadLen == 126 {
			var l uint16
			if err := binary.Read(c.reader, binary.BigEndian, &l); err != nil {
				return 0, nil, err
			}
			payloadLen = int64(l)
		} else if payloadLen == 127 {
			var l uint64
			if err := binary.Read(c.reader, binary.BigEndian, &l); err != nil {
				return 0, nil, err
			}
			payloadLen = int64(l)
		}

		var maskKey [4]byte
		if isMasked {
			if _, err := io.ReadFull(c.reader, maskKey[:]); err != nil {
				return 0, nil, err
			}
		}

		payload := make([]byte, payloadLen)
		if _, err := io.ReadFull(c.reader, payload); err != nil {
			return 0, nil, err
		}

		if isMasked {
			for i := int64(0); i < payloadLen; i++ {
				payload[i] ^= maskKey[i%4]
			}
		}

		switch opcode {
		case opPing:
			// Send pong frame
			_ = c.writeControl(opPong, payload)
		case opPong:
			// Keepalive response
			continue
		case opClose:
			c.Close()
			return opClose, payload, io.EOF
		default:
			return opcode, payload, nil
		}
	}
}

func (c *Conn) writeControl(opcode byte, payload []byte) error {
	c.writeMu.Lock()
	defer c.writeMu.Unlock()
	if c.closed {
		return nil
	}
	header := []byte{0x80 | opcode, byte(len(payload))}
	c.writer.Write(header)
	c.writer.Write(payload)
	return c.writer.Flush()
}

// Close closes the underlying network connection
func (c *Conn) Close() error {
	c.writeMu.Lock()
	defer c.writeMu.Unlock()
	if c.closed {
		return nil
	}
	c.closed = true
	return c.netConn.Close()
}

// SetDeadline sets network deadlines for read/write
func (c *Conn) SetDeadline(t time.Time) error {
	return c.netConn.SetDeadline(t)
}
