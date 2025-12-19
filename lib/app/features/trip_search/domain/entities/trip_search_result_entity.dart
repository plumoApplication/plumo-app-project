import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

/// Uma extensão da TripEntity que contém dados extras
/// retornados especificamente na busca (dados do motorista).
class TripSearchResultEntity extends TripEntity {
  final String driverName;
  final double driverRating;
  final double originalTotalPrice; // O preço total da viagem (A->D)
  final String displayOrigin;
  final String displayDestination;

  const TripSearchResultEntity({
    required super.id,
    required super.driverId,
    required super.originName,
    required super.destinationName,
    required super.departureTime,
    required super.availableSeats,
    super.status,
    required super.price, // Este será o preço do trecho (B->C)
    super.waypoints =
        const [], // Na busca rápida, não precisamos popular os waypoints

    required this.driverName,
    required this.driverRating,
    required this.originalTotalPrice,
    required this.displayOrigin,
    required this.displayDestination,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    driverName,
    driverRating,
    originalTotalPrice,
    displayOrigin,
    displayDestination,
  ];
}
