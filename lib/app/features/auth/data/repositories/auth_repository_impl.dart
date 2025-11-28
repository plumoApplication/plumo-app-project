import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:plumo/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Esta é a IMPLEMENTAÇÃO do nosso Repositório (o "Gerente")
// Note que ele 'implements' o contrato do DOMÍNIO (AuthRepository)

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  // (Mais tarde, poderíamos adicionar: final AuthLocalDataSource localDataSource)
  // (E também: final NetworkInfo networkInfo, para checar a internet)

  AuthRepositoryImpl({
    required this.remoteDataSource,
    // required this.localDataSource,
    // required this.networkInfo,
  });

  @override
  bool get isUserLoggedIn {
    // Por enquanto, apenas repassamos a chamada para o data source
    return remoteDataSource.isUserLoggedIn;
  }

  @override
  Future<Either<Failure, void>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Esta é a lógica principal do "Gerente"
    try {
      // 1. Tenta executar a ação do "trabalhador" (DataSource)
      await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 2. Se deu certo, retorna 'Right' (Sucesso) com 'void' (nada)
      return const Right(null);
    } on AuthException catch (e) {
      // 3. Se o DataSource lançou uma AuthException...
      // ...traduz para uma AuthFailure e retorna 'Left' (Falha)
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      // 4. Se o DataSource lançou uma ServerException...
      // ...traduz para uma ServerFailure e retorna 'Left' (Falha)
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithGoogle() async {
    try {
      await remoteDataSource.signInWithGoogle();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<supabase.AuthState> get onAuthStateChange =>
      remoteDataSource.onAuthStateChange;
}
