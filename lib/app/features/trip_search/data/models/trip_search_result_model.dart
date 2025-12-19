import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart'; // [NOVO IMPORT]
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';

class TripSearchResultModel extends TripSearchResultEntity {
  const TripSearchResultModel({
    required super.id,
    required super.driverId,
    required super.originName,
    required super.destinationName,
    required super.departureTime,
    required super.availableSeats,
    super.status,
    required super.price,
    required super.driverName,
    required super.driverRating,
    required super.originalTotalPrice,
    super.waypoints,
    required super.displayOrigin,
    required super.displayDestination,
  });

  factory TripSearchResultModel.fromMap(Map<String, dynamic> map) {
    return TripSearchResultModel(
      id: map['id'] as String?,
      driverId: map['driver_id'] ?? '',
      originName: map['origin_name'] ?? '',
      destinationName: map['destination_name'] ?? '',

      // Data e Hora
      departureTime: map['departure_time'] != null
          ? DateTime.parse(map['departure_time'])
          : DateTime.now(),

      availableSeats: map['available_seats'] ?? 0,
      status: map['status'],

      // Preços
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalTotalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,

      // Dados do Motorista
      driverName: map['driver_name'] ?? 'Motorista',
      driverRating: (map['driver_rating'] as num?)?.toDouble() ?? 5.0,

      displayOrigin: map['origin_name'] ?? '',
      displayDestination: map['destination_name'] ?? '',

      // Inicializa como lista vazia tipada
      waypoints: const [],
    );
  }

  // [CORREÇÃO: Removemos o @override pois Entity não tem copyWith]
  TripSearchResultModel copyWith({
    String? id,
    String? driverId,
    DateTime? departureTime,
    int? availableSeats,
    String? status,
    String? displayOrigin,
    String? displayDestination,

    // [CORREÇÃO: Mudamos de List<dynamic> para o tipo correto]
    List<TripWaypointEntity>? waypoints,

    String? originName,
    String? destinationName,
    double? price,
    String? driverName,
    double? driverRating,
    double? originalTotalPrice,
  }) {
    return TripSearchResultModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      originName: originName ?? this.originName,
      destinationName: destinationName ?? this.destinationName,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      status: status ?? this.status,
      price: price ?? this.price,
      displayOrigin: displayOrigin ?? this.displayOrigin,
      displayDestination: displayDestination ?? this.displayDestination,
      // Agora os tipos batem: List<TripWaypointEntity> com List<TripWaypointEntity>
      waypoints: waypoints ?? this.waypoints,

      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      originalTotalPrice: originalTotalPrice ?? this.originalTotalPrice,
    );
  }
}
