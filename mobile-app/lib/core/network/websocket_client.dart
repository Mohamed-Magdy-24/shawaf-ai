import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WsConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class IndustrialWebSocketClient {
  final String baseWsUrl;
  String _siteId;
  String get siteId => _siteId;
  final Duration heartbeatTimeout;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatCheckTimer;
  DateTime? _lastMessageTime;

  int _reconnectAttempts = 0;
  bool _isDisposed = false;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<WsConnectionStatus>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<WsConnectionStatus> get status => _statusController.stream;
  WsConnectionStatus currentStatus = WsConnectionStatus.disconnected;

  IndustrialWebSocketClient({
    this.baseWsUrl = 'ws://127.0.0.1:8080',
    required String siteId,
    this.heartbeatTimeout = const Duration(seconds: 10),
  }) : _siteId = siteId;

  void switchSite(String newSiteId, {String? ticket}) {
    if (_siteId == newSiteId && currentStatus == WsConnectionStatus.connected) return;
    _siteId = newSiteId;
    disconnect();
    connect(ticket: ticket);
  }

  void disconnect() {
    _heartbeatCheckTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _updateStatus(WsConnectionStatus.disconnected);
  }

  void connect({String? ticket, WebSocketChannel? customChannel}) {
    if (_isDisposed) return;

    _updateStatus(
      _reconnectAttempts > 0
          ? WsConnectionStatus.reconnecting
          : WsConnectionStatus.connecting,
    );

    try {
      if (customChannel != null) {
        _channel = customChannel;
      } else {
        final queryParam = ticket != null ? '?ticket=$ticket' : '';
        final uri = Uri.parse('$baseWsUrl/api/v1/sites/$siteId/ws-events$queryParam');
        _channel = WebSocketChannel.connect(uri);
      }

      _lastMessageTime = DateTime.now();
      _startHeartbeatMonitor();

      _subscription = _channel!.stream.listen(
        (data) {
          _lastMessageTime = DateTime.now();
          if (currentStatus != WsConnectionStatus.connected) {
            _updateStatus(WsConnectionStatus.connected);
            _reconnectAttempts = 0;
          }

          try {
            final decoded = jsonDecode(data.toString());
            if (decoded is Map<String, dynamic>) {
              _messageController.add(decoded);
            }
          } catch (_) {
            // Ignore non-json ping/pongs
          }
        },
        onError: (error) {
          _handleDisconnect();
        },
        onDone: () {
          _handleDisconnect();
        },
      );

      _updateStatus(WsConnectionStatus.connected);
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;

    if (_isDisposed) return;

    _updateStatus(WsConnectionStatus.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed || _reconnectTimer?.isActive == true) return;

    final backoffSeconds = (1 << _reconnectAttempts).clamp(1, 16);
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(seconds: backoffSeconds), () {
      if (!_isDisposed) {
        connect();
      }
    });
  }

  void _startHeartbeatMonitor() {
    _heartbeatCheckTimer?.cancel();
    _heartbeatCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_lastMessageTime != null && currentStatus == WsConnectionStatus.connected) {
        final elapsed = DateTime.now().difference(_lastMessageTime!);
        if (elapsed > heartbeatTimeout) {
          // Stale detected; trigger reconnect attempt
          _handleDisconnect();
        }
      }
    });
  }

  void _updateStatus(WsConnectionStatus newStatus) {
    currentStatus = newStatus;
    if (!_statusController.isClosed) {
      _statusController.add(newStatus);
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null && currentStatus == WsConnectionStatus.connected) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _heartbeatCheckTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _messageController.close();
    _statusController.close();
  }
}
