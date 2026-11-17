/// Strongly-typed configuration class for Shawaf AI.
/// All environment overrides are passed strictly via --dart-define.
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://127.0.0.1:8080/api/v1/ws',
  );

  static const String appTitle = 'Shawaf AI (شوف AI)';
}
