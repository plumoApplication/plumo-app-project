import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/my_trips/data/datasources/my_trips_remote_datasource.dart';
import 'package:plumo/app/features/my_trips/domain/repositories/my_trips_repository.dart';

// Esta é a IMPLEMENTAÇÃO do nosso Repositório (o "Gerente")

class MyTripsRepositoryImpl implements MyTripsRepository {
  final MyTripsRemoteDataSource remoteDataSource;
  // (No futuro, poderíamos adicionar um 'NetworkInfo' para checar a internet)

  MyTripsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyTrips() async {
    // (Aqui poderíamos adicionar a lógica de checar a internet primeiro)

    try {
      // 1. Tenta buscar os MODELOS (com lógica de JSON) no DataSource
      final bookingModels = await remoteDataSource.getMyTrips();

      // 2. Se deu certo, retorna 'Right' (Sucesso)
      //    O 'bookingModels' (uma List<BookingModel>) é compatível com
      //    o retorno List<BookingEntity> (pois BookingModel 'extends' BookingEntity).
      return Right(bookingModels);
    } on ServerException catch (e) {
      // 3. Se o DataSource lançou uma ServerException...
      //    ...traduz para uma ServerFailure e retorna 'Left' (Falha)
      return Left(ServerFailure(message: e.message));
    }
  }
}
