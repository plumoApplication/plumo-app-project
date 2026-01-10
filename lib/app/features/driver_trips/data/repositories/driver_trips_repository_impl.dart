import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_trips/data/datasources/driver_trips_remote_datasource.dart';
import 'package:plumo/app/features/driver_trips/domain/repositories/driver_trips_repository.dart';

// Esta é a IMPLEMENTAÇÃO do nosso Repositório (o "Gerente")

class DriverTripsRepositoryImpl implements DriverTripsRepository {
  final DriverTripsRemoteDataSource remoteDataSource;
  // (No futuro, poderíamos adicionar um 'NetworkInfo' para checar a internet)

  DriverTripsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TripEntity>>> getMyTrips() async {
    // (Aqui poderíamos adicionar a lógica de checar a internet primeiro)

    try {
      // 1. Tenta buscar os MODELOS (com lógica de JSON) no DataSource
      final tripModels = await remoteDataSource.getMyTrips();

      // 2. Se deu certo, retorna 'Right' (Sucesso)
      //    O 'tripModels' (uma List<TripModel>) é compatível com
      //    o retorno List<TripEntity> (pois TripModel 'extends' TripEntity).
      return Right(tripModels);
    } on ServerException catch (e) {
      // 3. Se o DataSource lançou uma ServerException...
      //    ...traduz para uma ServerFailure e retorna 'Left' (Falha)
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<void> getBookingStream() {
    // Apenas repassa o stream do DataSource
    return remoteDataSource.getBookingStream();
  }
}
