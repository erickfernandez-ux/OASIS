/// Server exceptions for Supabase error handling.
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

/// Local cache exceptions.
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}
