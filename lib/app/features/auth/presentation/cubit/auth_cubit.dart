import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';
// --- IMPORT ADICIONADO ---
import 'package:plumo/app/features/profile/domain/repositories/profile_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  // --- DEPENDÊNCIA ADICIONADA ---
  final ProfileRepository profileRepository;

  AuthCubit({
    required this.authRepository,
    required this.profileRepository, // <-- Injetada
  }) : super(AuthInitial());

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

  void clearErrorState() {
    // Se o estado atual for um erro, limpa para Unauthenticated
    if (state is AuthError) {
      emit(Unauthenticated());
    }
  }
}
