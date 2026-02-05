import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart'; // [NOVO IMPORT]
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';

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
    super.pickupFee,

    super.originLat,
    super.originLng,
    super.destinationLat,
    super.destinationLng,

    super.boardingPlaceName,
    super.boardingLat,
    super.boardingLng,
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

      availableSeats: map['current_available_seats'] ?? map['available_seats'],
      status: map['status'],

      // Preços
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalTotalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
      pickupFee: (map['pickup_fee'] as num?)?.toDouble() ?? 0.0,

      // Dados do Motorista
      driverName: map['driver_name'] ?? 'Motorista',
      driverRating: (map['driver_rating'] as num?)?.toDouble() ?? 5.0,

      displayOrigin: map['origin_name'] ?? '',
      displayDestination: map['destination_name'] ?? '',

      originLat: (map['origin_lat'] as num?)?.toDouble() ?? 0.0,
      originLng: (map['origin_lng'] as num?)?.toDouble() ?? 0.0,
      destinationLat: (map['destination_lat'] as num?)?.toDouble() ?? 0.0,
      destinationLng: (map['destination_lng'] as num?)?.toDouble() ?? 0.0,

      boardingPlaceName: map['boarding_place_name'],
      boardingLat: (map['boarding_lat'] as num?)?.toDouble(),
      boardingLng: (map['boarding_lng'] as num?)?.toDouble(),

      // Inicializa como lista vazia tipada
      waypoints: map['waypoints_data'] != null
          ? (map['waypoints_data'] as List)
                .map(
                  (x) => TripWaypointModel.fromMap(x as Map<String, dynamic>),
                )
                .toList()
          : const [],
    );
  }

  // [CORREÇÃO: Removemos o @override pois Entity não tem copyWith]
  TripSearchResultModel copyWithResult({
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
    double? pickupFee,
    double? originLat,
    double? originLng,

    String? boardingPlaceName,
    double? boardingLat,
    double? boardingLng,
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
      pickupFee: pickupFee ?? this.pickupFee,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,

      boardingPlaceName: boardingPlaceName ?? this.boardingPlaceName,
      boardingLat: boardingLat ?? this.boardingLat,
      boardingLng: boardingLng ?? this.boardingLng,
    );
  }
}
