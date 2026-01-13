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
  final double pickupFee; // Taxa fixa (default 0.0)
  final String? boardingPlaceName;
  final double? boardingLat;
  final double? boardingLng;
  final double price;

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
    this.pickupFee = 0.0, // Valor padrão
    this.boardingPlaceName,
    this.boardingLat,
    this.boardingLng,
    required this.price,
  });

  TripEntity copyWith({
    String? id,
    String? driverId,
    DateTime? departureTime,
    int? availableSeats,
    String? status,
    DateTime? createdAt,
    String? originName,
    double? originLat,
    double? originLng,
    String? destinationName,
    double? destinationLat,
    double? destinationLng,
    double? pickupFee,
    String? boardingPlaceName,
    double? boardingLat,
    double? boardingLng,
    double? price,
    List<TripWaypointEntity>? waypoints,
  }) {
    return TripEntity(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      originName: originName ?? this.originName,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationName: destinationName ?? this.destinationName,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      pickupFee: pickupFee ?? this.pickupFee,
      boardingPlaceName: boardingPlaceName ?? this.boardingPlaceName,
      boardingLat: boardingLat ?? this.boardingLat,
      boardingLng: boardingLng ?? this.boardingLng,
      price: price ?? this.price,
      waypoints: waypoints ?? this.waypoints,
    );
  }

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
    price,
  ];
}
