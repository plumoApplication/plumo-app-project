import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';

// Este é o CÉREBRO da nossa feature de autenticação.
// A UI (tela de login) irá chamar os métodos deste Cubit.
// O Cubit irá chamar o Repository (o "gerente")
// e emitir novos estados (que a UI irá escutar).

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  // O estado inicial é 'AuthInitial' (ainda não checamos nada)
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  /// Método chamado pela UI quando o usuário clica em "Login"
  Future<void> signIn({required String email, required String password}) async {
    // 1. Emite "Carregando" para a UI (mostrar um loading spinner)
    emit(AuthLoading());

    // 2. Chama o repositório (que chama o Supabase)
    final result = await authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 3. Processa o resultado do repositório (que é um 'Either')
    result.fold(
      // 3a. Se deu 'Left' (Falha)
      (failure) => emit(AuthError(message: failure.message)),
      // 3b. Se deu 'Right' (Sucesso)
      (_) => emit(Authenticated()),
    );
  }

  /// Método chamado pela UI quando o usuário clica em "Cadastrar"
  Future<void> signUp({required String email, required String password}) async {
    // 1. Emite "Carregando"
    emit(AuthLoading());

    // 2. Chama o repositório
    final result = await authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 3. Processa o resultado
    result.fold(
      // 3a. Se deu 'Left' (Falha)
      (failure) => emit(AuthError(message: failure.message)),
      // 3b. Se deu 'Right' (Sucesso)
      // Assumimos (para o MVP) que o cadastro já loga o usuário.
      (_) => emit(Authenticated()),
    );
  }

  /// Método chamado pela UI quando o usuário clica em "Sair"
  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await authRepository.signOut();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()), // Ao sair, o estado é 'Deslogado'
    );
  }

  /// Método chamado quando o app abre (Splash Screen)
  /// para verificar se já existe uma sessão ativa.
  void checkAuthStatus() {
    // Esta chamada é síncrona
    final isUserLoggedIn = authRepository.isUserLoggedIn;

    if (isUserLoggedIn) {
      emit(Authenticated());
    } else {
      emit(Unauthenticated());
    }
  }
}
