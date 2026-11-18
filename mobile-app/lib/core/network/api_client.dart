import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? errorCode;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errorCode,
  });

  @override
  String toString() => 'ApiException [$statusCode] $errorCode: $message';
}

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({
    this.baseUrl = 'http://127.0.0.1:8080',
    http.Client? client,
  }) : _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: e.toString(), errorCode: 'NETWORK_ERR');
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: e.toString(), errorCode: 'NETWORK_ERR');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String message = 'HTTP Error ${response.statusCode}';
    String? errorCode;
    try {
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic>) {
        message = json['message'] ?? json['error'] ?? message;
        errorCode = json['error_code'] ?? json['code'];
      }
    } catch (_) {}

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      errorCode: errorCode ?? 'HTTP_${response.statusCode}',
    );
  }

  void dispose() {
    _client.close();
  }
}
