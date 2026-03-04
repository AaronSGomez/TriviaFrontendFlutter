/// Compile-time flag: true when the app is built with --dart-define=IS_ADMIN=true
/// Use this to show admin-only UI and to register against the admin endpoint.
const bool kIsAdmin = bool.fromEnvironment('IS_ADMIN', defaultValue: false);
