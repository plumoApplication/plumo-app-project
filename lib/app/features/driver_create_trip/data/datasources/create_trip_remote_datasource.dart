import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';

abstract class CreateTripRemoteDataSource {
  /// Insere a viagem e retorna o ID gerado (String)
  Future<String> createTrip(TripModel trip);

  /// Insere a lista de waypoints
  Future<void> createTripWaypoints(List<TripWaypointModel> waypoints);
}
