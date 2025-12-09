import 'package:equatable/equatable.dart';

class TripWaypointEntity extends Equatable {
  final String? id;
  final String? tripId;
  final int order;
  final String placeName;
  final String placeGoogleId;
  final double latitude;
  final double longitude;
  final double price; // Preço da origem até este ponto
  final DateTime? createdAt;
  final String? boardingPlaceName; // Ex: "Rodoviária"
  final double? boardingLat;
  final double? boardingLng;

  const TripWaypointEntity({
    this.id,
    this.tripId,
    required this.order,
    required this.placeName,
    required this.placeGoogleId,
    required this.latitude,
    required this.longitude,
    required this.price,
    this.createdAt,
    this.boardingPlaceName,
    this.boardingLat,
    this.boardingLng,
  });

  @override
  List<Object?> get props => [
    id,
    tripId,
    order,
    placeName,
    placeGoogleId,
    latitude,
    longitude,
    price,
    createdAt,
    boardingPlaceName,
    boardingLat,
    boardingLng,
  ];
}
