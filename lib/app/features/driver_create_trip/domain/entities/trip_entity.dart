import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart';

// (Vamos criar o TripWaypointEntity a seguir)

class TripEntity extends Equatable {
  final String? id;
  final String? driverId;
  final DateTime departureTime;
  final int availableSeats;
  final String? status;
  final DateTime? createdAt;
  final String? originName;
  final double? originLat;
  final double? originLng;
  final String? destinationName;
  final double? destinationLat;
  final double? destinationLng;

  // Uma viagem 'contém' uma lista de pontos de parada
  final List<TripWaypointEntity> waypoints;

  const TripEntity({
    this.id,
    this.driverId,
    required this.departureTime,
    required this.availableSeats,
    this.status,
    this.createdAt,
    required this.waypoints,
    this.originName,
    this.originLat,
    this.originLng,
    this.destinationName,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  List<Object?> get props => [
    id,
    driverId,
    departureTime,
    availableSeats,
    status,
    createdAt,
    waypoints,
    originName,
    originLat,
    originLng,
    destinationName,
    destinationLat,
    destinationLng,
  ];
}
