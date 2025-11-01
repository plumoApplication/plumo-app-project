import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
// Esta é a camada de DOMÍNIO (DOMAIN)
// É um arquivo abstrato (um "contrato")
// Ele define O QUE o repositório de autenticação DEVE FAZER,
// mas não COMO ele faz.

// Usaremos o Supabase (na camada de DATA) para implementar este contrato.

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

  // Caso de uso: Verificar se há um usuário logado (ao abrir o app)
  // (Isso será importante para o "splash screen" ou "loading screen")
  // (No Supabase, isso é o 'session')
  bool get isUserLoggedIn;
}
