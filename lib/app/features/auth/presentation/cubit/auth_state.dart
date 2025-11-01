import 'package:equatable/equatable.dart';

// O 'Equatable' nos ajuda a comparar estados (ex: AuthLoading() == AuthLoading())

// Classe base abstrata para todos os nossos estados
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado Inicial: O app acabou de abrir, ainda não sabemos se o
/// usuário está logado ou não.
class AuthInitial extends AuthState {}

/// Estado de Carregamento: O usuário clicou em "Login" ou "Cadastro"
/// e estamos aguardando a resposta do Supabase.
class AuthLoading extends AuthState {}

/// Estado Autenticado: Login ou Cadastro foi um sucesso.
/// (No futuro, podemos guardar a 'entity' do Usuário aqui)
class Authenticated extends AuthState {}

/// Estado Não-Autenticado: O usuário não está logado,
/// fez logout ou a sessão expirou.
class Unauthenticated extends AuthState {}

/// Estado de Erro: Ocorreu uma falha (ex: senha errada, sem internet)
/// e precisamos mostrar uma mensagem para o usuário.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
