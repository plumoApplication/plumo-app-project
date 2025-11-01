// lib/app/core/errors/exceptions.dart

/// Exceção genérica para erros de servidor (API, Supabase, etc.)
class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'Ocorreu um erro no servidor.'});
}

/// Exceção para erros de autenticação específicos
class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
}

/// Exceção para falhas de cache local (Hive)
class CacheException implements Exception {
  final String message;
  CacheException({this.message = 'Ocorreu um erro ao acessar o cache local.'});
}
