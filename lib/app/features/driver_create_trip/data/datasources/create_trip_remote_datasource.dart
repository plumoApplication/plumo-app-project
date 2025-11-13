import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';

// Este é o contrato da camada de DADOS.
// Define o que o Supabase deve fazer.

abstract class CreateTripRemoteDataSource {
  /// Insere a viagem principal (sem os waypoints) na tabela 'trips'.
  ///
  /// Recebe o [TripModel] (que contém driver_id, departure_time, etc.)
  /// Retorna o 'id' da viagem que acabou de ser criada, para que
  /// possamos usá-lo para inserir os waypoints.
  ///
  /// Lança (throws) uma [ServerException] se o insert falhar.
  Future<String> createTrip(TripModel trip);

  /// Insere a lista de pontos de parada (waypoints) na
  /// tabela 'trip_waypoints'.
  ///
  /// Recebe a lista de [TripWaypointModel].
  /// Lança (throws) uma [ServerException] se o insert em lote falhar.
  Future<void> createTripWaypoints(List<TripWaypointModel> waypoints);
}
