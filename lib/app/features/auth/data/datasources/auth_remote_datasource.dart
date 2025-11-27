import 'package:supabase_flutter/supabase_flutter.dart';
// Para AuthChangeEvent

// Este é o contrato da camada de DADOS
// Ele define O QUE a nossa fonte de dados REMOTA (Supabase) deve fazer.
// Se algo der errado aqui (ex: Supabase joga um erro),
// ele deve lançar (throw) uma 'AuthException' ou 'ServerException'.

abstract class AuthRemoteDataSource {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future<void> updatePassword(String newPassword);

  Stream<AuthState> get onAuthStateChange;

  /// Verifica sincronicamente se existe uma sessão de usuário ativa no cliente.
  bool get isUserLoggedIn;
}
