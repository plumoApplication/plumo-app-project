import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:plumo/app/features/profile/domain/entities/profile_entity.dart';
import 'package:plumo/app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final profileModel = await remoteDataSource.getProfile();
      return Right(profileModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String fullName,
    required String cpf,
    required String phoneNumber,
    required DateTime birthDate,
  }) async {
    try {
      // Passa os dados brutos para o DataSource
      await remoteDataSource.updateProfile(
        fullName: fullName,
        cpf: cpf,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
