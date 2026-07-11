class AppEnvironment {

  static const enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const enableRealtime = bool.fromEnvironment(
    'ENABLE_REALTIME',
    defaultValue: false,
  );


  static const enableNetworkLogs = bool.fromEnvironment(
    'ENABLE_NETWORK_LOGS',
    defaultValue: false,
  );

  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
}
