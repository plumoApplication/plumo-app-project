import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/repositories/create_trip_repository.dart';

// Esta é a IMPLEMENTAÇÃO do nosso Repositório (o "Gerente")

class CreateTripRepositoryImpl implements CreateTripRepository {
  final CreateTripRemoteDataSource remoteDataSource;
  // (No futuro, poderíamos adicionar um 'NetworkInfo' para checar a internet)

  CreateTripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createTrip(TripEntity trip) async {
    try {
      final originWaypoint = trip.waypoints.first;
      final destinationWaypoint = trip.waypoints.last;
      final tripModel = TripModel(
        departureTime: trip.departureTime,
        availableSeats: trip.availableSeats,
        status: trip.status ?? 'scheduled', // Garante um status
        waypoints: trip.waypoints,
        originName: originWaypoint.placeName,
        originLat: originWaypoint.latitude,
        originLng: originWaypoint.longitude,
        destinationName: destinationWaypoint.placeName,
        destinationLat: destinationWaypoint.latitude,
        destinationLng: destinationWaypoint.longitude,
      );

      // 2. CHAMA O PASSO 1 (DataSource): Criar a 'trip' principal
      //    Isso insere na tabela 'trips' e retorna o novo 'id'
      final newTripId = await remoteDataSource.createTrip(tripModel);

      // 3. ATUALIZA OS WAYPOINTS EM MEMÓRIA:
      //    Agora que temos o 'newTripId', nós o atribuímos
      //    a cada waypoint na nossa lista.
      final List<TripWaypointModel> waypointsWithId = [];
      for (final wpEntity in trip.waypoints) {
        waypointsWithId.add(
          TripWaypointModel(
            tripId: newTripId, // <-- A MÁGICA ACONTECE AQUI
            order: wpEntity.order,
            placeName: wpEntity.placeName,
            placeGoogleId: wpEntity.placeGoogleId,
            latitude: wpEntity.latitude,
            longitude: wpEntity.longitude,
            price: wpEntity.price,
          ),
        );
      }

      // 4. CHAMA O PASSO 2 (DataSource): Inserir os waypoints em lote
      //    Agora todos os waypoints têm o 'trip_id' correto.
      await remoteDataSource.createTripWaypoints(waypointsWithId);

      // 5. Se tudo deu certo, retorna Sucesso (Right)
      return const Right(null);
    } on ServerException catch (e) {
      // 6. Se qualquer um dos 'await' (Passo 2 ou 4) falhar,
      //    captura a exceção e retorna Falha (Left)
      return Left(ServerFailure(message: e.message));
    }
  }
}
