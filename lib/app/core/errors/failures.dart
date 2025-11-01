// lib/app/core/errors/failures.dart
import 'package:equatable/equatable.dart';

// A classe 'Failure' é o que a UI (Cubit) receberá
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Falha genérica de servidor
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Falha específica de autenticação (ex: e-mail errado, senha errada)
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Falha de cache local
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
