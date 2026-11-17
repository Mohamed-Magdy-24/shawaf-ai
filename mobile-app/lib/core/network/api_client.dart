import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../errors/exceptions.dart';

abstract class IApiClient {
  void setAuthToken(String? token);
  String? get authToken;
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams});
  Future<dynamic> post(String endpoint, {dynamic body});
  Future<dynamic> put(String endpoint, {dynamic body});
  Future<dynamic> delete(String endpoint);
}

class ApiClient implements IApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  String? _authToken;

  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _httpClient = httpClient ?? http.Client();

  @override
  void setAuthToken(String? token) {
    _authToken = token;
  }

  @override
  String? get authToken => _authToken;

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$baseUrl$cleanEndpoint';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  @override
  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _httpClient
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 8));
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
          'Network error connecting to $baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException(
          'Request timed out connecting to backend server');
    }
  }

  @override
  Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final uri = _buildUri(endpoint);
      final encodedBody =
          body is String ? body : (body != null ? jsonEncode(body) : null);
      final response = await _httpClient
          .post(uri, headers: _buildHeaders(), body: encodedBody)
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
          'Network error connecting to $baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException(
          'Request timed out connecting to backend server');
    }
  }

  @override
  Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final uri = _buildUri(endpoint);
      final encodedBody =
          body is String ? body : (body != null ? jsonEncode(body) : null);
      final response = await _httpClient
          .put(uri, headers: _buildHeaders(), body: encodedBody)
          .timeout(const Duration(seconds: 8));
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
          'Network error connecting to $baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException(
          'Request timed out connecting to backend server');
    }
  }

  @override
  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _httpClient
          .delete(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 8));
      return _processResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
          'Network error connecting to $baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException(
          'Request timed out connecting to backend server');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    } else if (response.statusCode == 401) {
      throw const AuthException('Session expired or unauthorized credentials');
    } else if (response.statusCode == 403) {
      throw const ForbiddenException(
          'Access denied by system governance policy');
    } else {
      throw ServerException(
        'Server returned error: ${response.body}',
        response.statusCode,
      );
    }
  }
}
