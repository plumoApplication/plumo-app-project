import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Esta é a IMPLEMENTAÇÃO do nosso DataSource.
// É ela quem "suja as mãos" e chama o Supabase.
// Note que ela 'implements' (implementa) o contrato que acabamos de criar.

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  // Usaremos injeção de dependência (GetIt) para fornecer o 'supabaseClient'
  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  bool get isUserLoggedIn {
    // Verifica se há uma sessão de usuário ativa no Supabase
    return supabaseClient.auth.currentSession != null;
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Chama o método de login do Supabase
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on supabase.AuthException catch (e) {
      // Captura o 'AuthException' específico do Supabase
      // e lança a NOSSA 'AuthException' com a mensagem de erro.
      // Isso é importante para traduzir o erro.
      throw AuthException(message: e.message);
    } catch (e) {
      // Captura qualquer outro erro (ex: sem internet, erro de servidor)
      // e lança a NOSSA 'ServerException' genérica.
      throw ServerException(
        message: 'Erro ao tentar fazer login: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Chama o método de logout do Supabase
      await supabaseClient.auth.signOut();
    } catch (e) {
      // Captura qualquer erro e lança nossa 'ServerException'
      throw ServerException(
        message: 'Erro ao tentar fazer logout: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Chama o método de cadastro (sign up) do Supabase
      await supabaseClient.auth.signUp(
        email: email,
        password: password,
        // (Mais tarde, adicionaremos os dados extras como Nome, CPF, etc. aqui
        // usando o parâmetro 'data:')
      );
    } on supabase.AuthException catch (e) {
      // Captura o 'AuthException' específico do Supabase
      throw AuthException(message: e.message);
    } catch (e) {
      // Captura qualquer outro erro
      throw ServerException(
        message: 'Erro ao tentar criar conta: ${e.toString()}',
      );
    }
  }
}
