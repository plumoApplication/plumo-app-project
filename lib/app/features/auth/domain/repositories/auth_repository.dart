import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class AuthRepository {
  // Caso de uso: Login com E-mail e Senha
  Future<Either<Failure, void>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Caso de uso: Cadastro (Sign Up) com E-mail e Senha
  // (Mais tarde, adicionaremos os dados extras como Nome, CPF, etc.)
  Future<Either<Failure, void>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Caso de uso: Fazer Logout
  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, void>> updatePassword(String newPassword);

  Future<Either<Failure, void>> signInWithGoogle();

  Stream<supabase.AuthState> get onAuthStateChange;

  // Caso de uso: Verificar se há um usuário logado (ao abrir o app)
  // (Isso será importante para o "splash screen" ou "loading screen")
  // (No Supabase, isso é o 'session')
  bool get isUserLoggedIn;
}
