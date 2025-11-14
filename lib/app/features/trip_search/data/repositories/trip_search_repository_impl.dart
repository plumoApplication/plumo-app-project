import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/trip_search/data/datasources/trip_search_remote_datasource.dart';
import 'package:plumo/app/features/trip_search/domain/repositories/trip_search_repository.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

// Esta é a IMPLEMENTAÇÃO do nosso Repositório (o "Gerente")

class TripSearchRepositoryImpl implements TripSearchRepository {
  final TripSearchRemoteDataSource remoteDataSource;
  // (No futuro, poderíamos adicionar um 'NetworkInfo' para checar a internet)

  TripSearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TripEntity>>> searchTrips({
    required Place origin,
    required Place destination,
    required DateTime date,
  }) async {
    try {
      // 1. Tenta buscar os MODELOS (com lógica de JSON) no DataSource
      final tripModels = await remoteDataSource.searchTrips(
        origin: origin,
        destination: destination,
        date: date,
      );

      // 2. Se deu certo, retorna 'Right' (Sucesso)
      //    (Como TripModel 'extends' TripEntity, a lista é compatível)
      return Right(tripModels);
    } on ServerException catch (e) {
      // 3. Se o DataSource (RPC) lançou uma ServerException...
      //    ...traduz para uma ServerFailure e retorna 'Left' (Falha)
      return Left(ServerFailure(message: e.message));
    }
  }
}
