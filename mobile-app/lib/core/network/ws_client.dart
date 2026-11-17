import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class IWsClient {
  Stream<dynamic> get messages;
  bool get isConnected;
  void connect(String endpoint, {String? token});
  void disconnect();
}

class WsClient implements IWsClient {
  final String baseWsUrl;
  WebSocketChannel? _channel;
  final StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();
  bool _isConnected = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  String? _currentEndpoint;
  String? _currentToken;

  WsClient({String? baseWsUrl})
      : baseWsUrl = baseWsUrl ??
            const String.fromEnvironment('WS_BASE_URL',
                defaultValue: 'ws://127.0.0.1:8080/api/v1/ws');

  @override
  Stream<dynamic> get messages => _controller.stream;

  @override
  bool get isConnected => _isConnected;

  @override
  void connect(String endpoint, {String? token}) {
    _currentEndpoint = endpoint;
    _currentToken = token;
    _disposed = false;
    _establishConnection();
  }

  void _establishConnection() {
    if (_disposed) return;
    try {
      final tokenQuery = _currentToken != null ? '?ticket=$_currentToken' : '';
      final fullUrl = '$baseWsUrl$_currentEndpoint$tokenQuery';
      _channel = WebSocketChannel.connect(Uri.parse(fullUrl));
      _isConnected = true;
      _reconnectAttempts = 0;

      _channel?.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data.toString());
            _controller.add(decoded);
          } catch (_) {
            _controller.add(data);
          }
        },
        onError: (err) {
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          _isConnected = false;
          _scheduleReconnect();
        },
      );
    } catch (_) {
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectAttempts++;
    final delaySeconds = min(pow(2, _reconnectAttempts).toInt(), 30);
    Timer(Duration(seconds: delaySeconds), () {
      if (!_disposed && !_isConnected) {
        _establishConnection();
      }
    });
  }

  @override
  void disconnect() {
    _disposed = true;
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
  }
}
