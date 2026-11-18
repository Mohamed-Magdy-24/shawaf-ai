class AppConfig {
  final String apiBaseUrl;
  final String wsBaseUrl;
  final String defaultSiteId;
  final String? authToken;
  final bool isProduction;

  const AppConfig({
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.defaultSiteId,
    this.authToken,
    this.isProduction = false,
  });

  /// Factory constructor resolving configuration from compile-time environment defines
  /// e.g. flutter run --dart-define=API_BASE_URL=https://edge.factory.internal:8080
  factory AppConfig.fromEnvironment() {
    const api = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8080');
    const ws = String.fromEnvironment('WS_BASE_URL', defaultValue: 'ws://127.0.0.1:8080');
    const site = String.fromEnvironment('DEFAULT_SITE_ID', defaultValue: 'site_bnf');
    const token = String.fromEnvironment('AUTH_TOKEN', defaultValue: '');
    const isProd = bool.fromEnvironment('dart.vm.product', defaultValue: false);

    // Validate production URL constraints (anti-insecure defaults)
    if (isProd) {
      if (api.startsWith('http://') && !api.contains('localhost') && !api.contains('127.0.0.1')) {
        throw StateError('Production configuration requires HTTPS endpoint. Insecure HTTP rejected: $api');
      }
      if (ws.startsWith('ws://') && !ws.contains('localhost') && !ws.contains('127.0.0.1')) {
        throw StateError('Production configuration requires WSS endpoint. Insecure WS rejected: $ws');
      }
    }

    return AppConfig(
      apiBaseUrl: api,
      wsBaseUrl: ws,
      defaultSiteId: site,
      authToken: token.isNotEmpty ? token : null,
      isProduction: isProd,
    );
  }
}
