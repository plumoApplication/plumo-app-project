import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    // O construtor agora aceita os nulos da 'Entity'
    super.id,
    super.driverId,
    required super.departureTime,
    required super.availableSeats,
    super.status,
    super.createdAt,
    required super.waypoints,
  });

  /// fromMap (lendo do banco) - SEMPRE TERÁ OS DADOS (não nulos)
  factory TripModel.fromMap(Map<String, dynamic> map) {
    final waypointsData = map['trip_waypoints'] as List<dynamic>? ?? [];

    return TripModel(
      id: map['id'] as String,
      driverId: map['driver_id'] as String,
      departureTime: DateTime.parse(map['departure_time'] as String),
      availableSeats: map['available_seats'] as int,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      waypoints: waypointsData
          .map(
            (waypointMap) =>
                TripWaypointModel.fromMap(waypointMap as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// toMap (enviando para o banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driver_id': driverId,
      'departure_time': departureTime.toIso8601String(),
      'available_seats': availableSeats,
      'status': status,
      'created_at': createdAt?.toIso8601String(), // <-- Lida com nulo
      'trip_waypoints': waypoints
          .map((waypoint) => (waypoint as TripWaypointModel).toMap())
          .toList(),
    };
  }

  /// Método 'copyWith' para nos ajudar a criar a entidade
  TripModel copyWith({
    String? id,
    String? driverId,
    DateTime? departureTime,
    int? availableSeats,
    String? status,
    DateTime? createdAt,
    List<TripWaypointEntity>? waypoints,
  }) {
    return TripModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      waypoints: waypoints ?? this.waypoints,
    );
  }
}
