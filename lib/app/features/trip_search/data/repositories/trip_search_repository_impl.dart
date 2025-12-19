import 'package:dartz/dartz.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/trip_search/data/datasources/trip_search_remote_datasource.dart';
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';
import 'package:plumo/app/features/trip_search/domain/repositories/trip_search_repository.dart';

class TripSearchRepositoryImpl implements TripSearchRepository {
  final TripSearchRemoteDataSource remoteDataSource;

  TripSearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TripSearchResultEntity>>> searchTrips({
    required Place origin,
    required Place destination,
    required DateTime date,
  }) async {
    try {
      // O DataSource já retorna List<TripSearchResultModel>
      final resultModels = await remoteDataSource.searchTrips(
        origin: origin,
        destination: destination,
        date: date,
      );

      // Como o Model estende a Entity, podemos retornar direto.
      // A lista de Models é compatível com a lista de Entities.
      return Right(resultModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      // Captura erros genéricos não previstos
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
