class AppConfig {
  const AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'RACHEETA_API_BASE_URL',
    defaultValue: 'https://racheeta.pythonanywhere.com/',
  );

  static const String authorizationPrefix = 'JWT';
}
