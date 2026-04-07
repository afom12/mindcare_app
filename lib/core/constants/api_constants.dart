/// Backend base URL. For Android emulator use `http://10.0.2.2:5000/api/v1`
/// if your machine runs the API on localhost.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api/v1',
  );

  /// Student therapist endpoints live under this path (no trailing slash).
  /// Default: `/therapist` → `/therapist/request`, `/therapist/status`, etc.
  /// If your server uses nested routes, set e.g. `--dart-define=THERAPIST_PATH_PREFIX=/student/therapist`
  static const String therapistPathPrefix = String.fromEnvironment(
    'THERAPIST_PATH_PREFIX',
    defaultValue: '/therapist',
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
