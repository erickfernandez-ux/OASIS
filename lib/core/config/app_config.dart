/// Centralized application configuration.
/// Sensitive values must be injected via environment variables in production.
class AppConfig {
  const AppConfig();

  static const String supabaseUrl = 'https://SUPABASE_URL.placeholder';
  static const String supabaseAnonKey = 'SUPABASE_ANON_KEY.placeholder';
}
