import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart';

class TripWaypointModel extends TripWaypointEntity {
  const TripWaypointModel({
    // O construtor agora aceita os nulos da 'Entity'
    super.id,
    super.tripId,
    required super.order,
    required super.placeName,
    required super.placeGoogleId,
    required super.latitude,
    required super.longitude,
    required super.price,
    super.createdAt,
    super.boardingPlaceName,
    super.boardingLat,
    super.boardingLng,
  });

  factory TripWaypointModel.fromMap(Map<String, dynamic> map) {
    return TripWaypointModel(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      order: map['order'] as int,
      placeName: map['place_name'] as String,
      placeGoogleId: map['place_google_id'] as String? ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      boardingPlaceName: map['boarding_place_name'] as String?,
      boardingLat: map['boarding_lat'] != null
          ? (map['boarding_lat'] as num).toDouble()
          : null,
      boardingLng: map['boarding_lng'] != null
          ? (map['boarding_lng'] as num).toDouble()
          : null,
    );
  }

  /// toMap (enviando para o banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'order': order,
      'place_name': placeName,
      'place_google_id': placeGoogleId,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'boarding_place_name': boardingPlaceName,
      'boarding_lat': boardingLat,
      'boarding_lng': boardingLng,
    };
  }
}
