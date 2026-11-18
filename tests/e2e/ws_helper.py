import socket
import base64
import os
import json
import urllib.request
import struct

class SimpleWebSocketClient:
    """Minimal zero-dependency RFC 6455 WebSocket client for e2e integration testing."""
    def __init__(self, host: str, port: int, path: str, timeout: float = 5.0):
        self.sock = socket.create_connection((host, port), timeout=timeout)
        key = base64.b64encode(os.urandom(16)).decode()
        handshake = (
            f"GET {path} HTTP/1.1\r\n"
            f"Host: {host}:{port}\r\n"
            f"Upgrade: websocket\r\n"
            f"Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            f"Sec-WebSocket-Version: 13\r\n\r\n"
        )
        self.sock.sendall(handshake.encode())
        res = b""
        while b"\r\n\r\n" not in res:
            chunk = self.sock.recv(1024)
            if not chunk:
                break
            res += chunk
        status_line = res.split(b"\r\n")[0].decode("utf-8", errors="ignore")
        if "101" not in status_line:
            raise ConnectionError(f"WebSocket upgrade rejected: {status_line}")

    def recv_json(self, timeout: float = 5.0):
        self.sock.settimeout(timeout)
        header = self.sock.recv(2)
        if len(header) < 2:
            return None
        b1, b2 = header[0], header[1]
        opcode = b1 & 0x0F
        masked = bool(b2 & 0x80)
        payload_len = b2 & 0x7F
        if payload_len == 126:
            ext = self.sock.recv(2)
            payload_len = struct.unpack("!H", ext)[0]
        elif payload_len == 127:
            ext = self.sock.recv(8)
            payload_len = struct.unpack("!Q", ext)[0]

        mask_key = None
        if masked:
            mask_key = self.sock.recv(4)

        data = bytearray()
        while len(data) < payload_len:
            chunk = self.sock.recv(payload_len - len(data))
            if not chunk:
                break
            data.extend(chunk)

        if masked and mask_key:
            data = bytearray(b ^ mask_key[i % 4] for i, b in enumerate(data))

        if opcode == 0x01:  # Text frame
            return json.loads(data.decode("utf-8"))
        elif opcode == 0x08:  # Connection close
            return None
        return None

    def close(self):
        try:
            self.sock.close()
        except Exception:
            pass
