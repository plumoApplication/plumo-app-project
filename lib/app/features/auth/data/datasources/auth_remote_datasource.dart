import 'package:plumo/app/core/errors/exceptions.dart'; // Nossas exceções customizadas

// Este é o contrato da camada de DADOS
// Ele define O QUE a nossa fonte de dados REMOTA (Supabase) deve fazer.
// Se algo der errado aqui (ex: Supabase joga um erro),
// ele deve lançar (throw) uma 'AuthException' ou 'ServerException'.

abstract class AuthRemoteDataSource {
  /// Chama a API do Supabase para fazer Login.
  ///
  /// Lança (throws) uma [AuthException] para erros de autenticação.
  /// Lança (throws) uma [ServerException] para outros erros de servidor.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Chama a API do Supabase para fazer Cadastro (Sign Up).
  ///
  /// Lança (throws) uma [AuthException] para erros de autenticação.
  /// Lança (throws) uma [ServerException] para outros erros de servidor.
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Chama a API do Supabase para fazer Logout.
  ///
  /// Lança (throws) uma [ServerException] para erros de servidor.
  Future<void> signOut();

  /// Verifica sincronicamente se existe uma sessão de usuário ativa no cliente.
  bool get isUserLoggedIn;
}
