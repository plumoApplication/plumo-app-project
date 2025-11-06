import 'package:equatable/equatable.dart';
// --- IMPORT ADICIONADO ---
import 'package:plumo/app/features/profile/domain/entities/profile_entity.dart';

// Classe base abstrata
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado Inicial
class AuthInitial extends AuthState {}

/// Estado de Carregamento
class AuthLoading extends AuthState {}

/// --- ESTADO ATUALIZADO ---
/// Estado Autenticado: Login/Cadastro sucesso E perfil completo.
/// Agora ele carrega a entidade do perfil.
class Authenticated extends AuthState {
  final ProfileEntity profile; // <-- DADO ADICIONADO

  const Authenticated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// --- NOVO ESTADO ADICIONADO ---
/// Estado "Perfil Incompleto": O usuário está logado (autenticado),
/// mas 'profile.isProfileComplete' retornou 'false'.
class ProfileIncomplete extends AuthState {
  final ProfileEntity profile; // <-- DADO ADICIONADO

  const ProfileIncomplete({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Estado Não-Autenticado: O usuário não está logado.
class Unauthenticated extends AuthState {}

/// Estado de Erro: Ocorreu uma falha
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
