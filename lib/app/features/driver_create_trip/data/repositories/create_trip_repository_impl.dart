import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/repositories/create_trip_repository.dart';

class CreateTripRepositoryImpl implements CreateTripRepository {
  final CreateTripRemoteDataSource remoteDataSource;

  CreateTripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Unit>> createTrip(TripEntity trip) async {
    try {
      // 1. Converter Entity para Model (Cast seguro pois o Cubit cria como Model)
      // Se não for possível o cast, criamos um novo Model com os dados da Entity
      final tripModel = trip is TripModel
          ? trip
          : TripModel(
              id: trip.id,
              driverId: trip.driverId,
              departureTime: trip.departureTime,
              availableSeats: trip.availableSeats,
              status: trip.status,
              createdAt: trip.createdAt,
              waypoints:
                  trip.waypoints, // Passamos a lista original por enquanto
              originName: trip.originName,
              originLat: trip.originLat,
              originLng: trip.originLng,
              destinationName: trip.destinationName,
              destinationLat: trip.destinationLat,
              destinationLng: trip.destinationLng,
              pickupFee: trip.pickupFee,
              boardingPlaceName: trip.boardingPlaceName,
              boardingLat: trip.boardingLat,
              boardingLng: trip.boardingLng,
            );

      // 2. Passo A: Criar a Viagem Principal
      final newTripId = await remoteDataSource.createTrip(tripModel);

      // 3. Passo B: Preparar Waypoints com o ID gerado
      if (tripModel.waypoints.isNotEmpty) {
        final List<TripWaypointModel> waypointsWithId = [];

        for (final wp in tripModel.waypoints) {
          // Converte Entity Waypoint para Model Waypoint e adiciona o ID
          waypointsWithId.add(
            TripWaypointModel(
              tripId: newTripId, // VINCULA AO PAI
              order: wp.order,
              placeName: wp.placeName,
              placeGoogleId: wp.placeGoogleId,
              latitude: wp.latitude,
              longitude: wp.longitude,
              price: wp.price,
              boardingPlaceName: wp.boardingPlaceName,
              boardingLat: wp.boardingLat,
              boardingLng: wp.boardingLng,
            ),
          );
        }

        // 4. Passo C: Salvar Waypoints
        await remoteDataSource.createTripWaypoints(waypointsWithId);
      }

      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
