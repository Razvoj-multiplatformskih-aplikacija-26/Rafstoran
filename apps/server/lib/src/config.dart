final class ServerConfig {
  const ServerConfig({
    required this.host,
    required this.port,
    required this.databaseUrl,
    required this.corsOrigins,
    this.raceDelay = Duration.zero,
  });

  factory ServerConfig.fromEnvironment(Map<String, String> environment) => ServerConfig(
    host: environment['HOST'] ?? '127.0.0.1',
    port: int.parse(environment['PORT'] ?? '8080'),
    databaseUrl:
        environment['DATABASE_URL'] ??
        (throw StateError('DATABASE_URL is not set. Copy .env.example to .env in the repository root.')),
    corsOrigins: (environment['CORS_ORIGINS'] ?? 'http://localhost:8081').split(','),
    raceDelay: Duration(milliseconds: int.parse(environment['RACE_DELAY_MS'] ?? '0')),
  );

  final String host;
  final int port;
  final String databaseUrl;
  final List<String> corsOrigins;
  final Duration raceDelay;
}
