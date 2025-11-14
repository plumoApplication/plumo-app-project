import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart';

/// Modelo de UI (Helper) para guardar os dados processados
/// que serão exibidos no card de resultado.
class SearchResultItem {
  final TripEntity fullTrip; // A viagem completa (A->D)
  final TripWaypointEntity
  originWaypoint; // O ponto A (ou B) que o passageiro buscou
  final TripWaypointEntity
  destinationWaypoint; // O ponto B (ou C) que o passageiro buscou
  final double calculatedPrice; // O preço (ex: Preço B - Preço A)

  SearchResultItem({
    required this.fullTrip,
    required this.originWaypoint,
    required this.destinationWaypoint,
    required this.calculatedPrice,
  });
}
