import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_earnings/data/datasources/earnings_remote_datasource.dart';
import 'package:plumo/app/features/driver_earnings/domain/entities/driver_earnings_entity.dart';
import 'package:plumo/app/features/driver_earnings/domain/repositories/earnings_repository.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDataSource remoteDataSource;

  EarningsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DriverEarningsEntity>> getEarnings({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await remoteDataSource.getEarnings(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
