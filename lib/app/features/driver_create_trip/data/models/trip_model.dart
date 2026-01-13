import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    super.id,
    super.driverId,
    required super.departureTime,
    required super.availableSeats,
    super.status,
    super.createdAt,
    required super.waypoints,
    super.originName,
    super.originLat,
    super.originLng,
    super.destinationName,
    super.destinationLat,
    super.destinationLng,
    super.pickupFee = 0.0,
    super.boardingPlaceName,
    super.boardingLat,
    super.boardingLng,
    required super.price,
  });

  /// FROM MAP (Banco -> App)
  factory TripModel.fromMap(Map<String, dynamic> map) {
    final waypointsData = map['trip_waypoints'] as List<dynamic>? ?? [];

    return TripModel(
      id: map['id'] as String?,
      driverId: map['driver_id'] as String?,
      departureTime: DateTime.parse(map['departure_time'] as String),
      availableSeats: map['available_seats'] as int,
      status: map['status'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      waypoints: waypointsData
          .map((w) => TripWaypointModel.fromMap(w as Map<String, dynamic>))
          .toList(),

      originName: map['origin_name'] as String?,
      originLat: (map['origin_lat'] as num?)?.toDouble(),
      originLng: (map['origin_lng'] as num?)?.toDouble(),

      destinationName: map['destination_name'] as String?,
      destinationLat: (map['destination_lat'] as num?)?.toDouble(),
      destinationLng: (map['destination_lng'] as num?)?.toDouble(),

      pickupFee: (map['pickup_fee'] as num?)?.toDouble() ?? 0.0,

      boardingPlaceName: map['boarding_place_name'] as String?,
      boardingLat: (map['boarding_lat'] as num?)?.toDouble(),
      boardingLng: (map['boarding_lng'] as num?)?.toDouble(),

      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// TO MAP (App -> Banco)
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'driver_id': driverId,
      'departure_time': departureTime.toIso8601String(),
      'available_seats': availableSeats,
      'status': status ?? 'scheduled',

      'origin_name': originName,
      'origin_lat': originLat,
      'origin_lng': originLng,

      'destination_name': destinationName,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,

      'pickup_fee': pickupFee,
      'boarding_place_name': boardingPlaceName,
      'boarding_lat': boardingLat,
      'boarding_lng': boardingLng,

      'price': price,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  /// COPY WITH (Método Essencial Adicionado)
  @override
  TripModel copyWith({
    String? id,
    String? driverId,
    DateTime? departureTime,
    int? availableSeats,
    String? status,
    DateTime? createdAt,
    List<TripWaypointEntity>? waypoints,
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
  }) {
    return TripModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      waypoints: waypoints ?? this.waypoints,
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
    );
  }
}
