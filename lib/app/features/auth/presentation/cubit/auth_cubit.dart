import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';
import 'package:plumo/app/features/profile/domain/repositories/profile_repository.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  late StreamSubscription _authSubscription;

  AuthCubit({
    required this.authRepository,
    required this.profileRepository, // <-- Injetada
  }) : super(AuthInitial()) {
    _monitorAuthState();
  }

  void _monitorAuthState() {
    _authSubscription = authRepository.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        // OPA! O usuário veio pelo link de reset.
        emit(AuthRecoveringPassword());
      }
      // (Podemos tratar outros eventos aqui se quisermos, como signedOut)
    });
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  Future<void> completePasswordReset(String newPassword) async {
    emit(AuthLoading());

    // 1. Atualiza a senha (o usuário já está logado via link mágico)
    final result = await authRepository.updatePassword(newPassword);

    result.fold((failure) => emit(AuthError(message: failure.message)), (
      _,
    ) async {
      // 2. SUCESSO! Agora deslogamos para ele entrar com a nova senha.
      await authRepository.signOut();
      emit(Unauthenticated()); // Isso levará para a LoginPage
    });
  }

  /// Nova função privada para checar o perfil
  /// Esta função é chamada DEPOIS que confirmamos que o usuário está logado.
  Future<void> _checkProfileStatus() async {
    // Busca o perfil no repositório
    final profileResult = await profileRepository.getProfile();

    profileResult.fold(
      // 1. Falha ao buscar o perfil
      (failure) {
        // Se não conseguirmos buscar o perfil (ex: erro de rede,
        // ou o gatilho falhou), emitimos um erro grave.
        emit(
          AuthError(message: 'Falha ao carregar seu perfil. Tente novamente.'),
        );
      },
      // 2. Sucesso ao buscar o perfil
      (profile) {
        // Verificamos o 'getter' que criamos na ProfileEntity
        if (profile.isProfileComplete) {
          // Perfil completo! Emite Autenticado (com dados)
          emit(Authenticated(profile: profile));
        } else {
          // Perfil incompleto. Emite ProfileIncomplete (com dados)
          emit(ProfileIncomplete(profile: profile));
        }
      },
    );
  }

  /// Método chamado pela UI quando o usuário clica em "Login"
  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());

    final result = await authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      // Falha no Login (ex: senha errada)
      (failure) => emit(AuthError(message: failure.message)),
      // Sucesso no Login
      (_) async {
        // Se o login deu certo, IMEDIATAMENTE checa o perfil
        await _checkProfileStatus();
      },
    );
  }

  /// Método chamado pela UI quando o usuário clica em "Cadastrar"
  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());

    final result = await authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      // Falha no Cadastro (ex: e-mail já existe)
      (failure) => emit(AuthError(message: failure.message)),
      // Sucesso no Cadastro
      (_) {
        // --- LÓGICA CORRIGIDA ---
        // NÃO chama _checkProfileStatus.
        // Apenas informa a UI que a conta foi criada.
        // O usuário agora deve fazer o LOGIN manualmente.
        emit(
          const AuthSuccess(
            message: 'Conta criada com sucesso! Por favor, faça o login.',
          ),
        );
      },
    );
  }

  /// Método chamado pela UI quando o usuário clica em "Sair"
  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await authRepository.signOut();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()), // Logout sempre leva a Deslogado
    );
  }

  /// Método chamado quando o app abre (Splash Screen)
  void checkAuthStatus() async {
    final isUserLoggedIn = authRepository.isUserLoggedIn;

    if (isUserLoggedIn) {
      // Se o Supabase diz que há uma sessão,
      // vamos checar o perfil, mas de forma segura.

      final profileResult = await profileRepository
          .getProfile(); // <-- Chamamos direto

      profileResult.fold(
        // 1. FALHA (Sessão Stale/Ruim ou DB offline)
        (failure) async {
          // Se falharmos em buscar o perfil no app open,
          // a sessão é inválida. DESLOGUE SILENCIOSAMENTE.
          await authRepository.signOut();
          emit(Unauthenticated()); // Emite um estado limpo.
        },
        // 2. SUCESSO
        (profile) {
          // O perfil foi carregado, agora verificamos se está completo.
          if (profile.isProfileComplete) {
            emit(Authenticated(profile: profile));
          } else {
            emit(ProfileIncomplete(profile: profile));
          }
        },
      );
    } else {
      // Se não há sessão, emite Deslogado
      emit(Unauthenticated());
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());

    final result = await authRepository.resetPassword(email);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordResetSent()),
    );
  }

  // Método auxiliar para limpar estados (ex: voltar do sucesso para o form)
  void resetState() {
    emit(Unauthenticated());
  }

  void clearErrorState() {
    // Se o estado atual for um erro, limpa para Unauthenticated
    if (state is AuthError) {
      emit(Unauthenticated());
    }
  }
}
