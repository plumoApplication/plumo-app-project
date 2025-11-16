import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

// Esta é a Entidade de Domínio "limpa"
class BookingEntity extends Equatable {
  final String? id; // Nulo ao criar
  final String tripId;
  final String passengerId;
  final String driverId;
  final String? status; // Nulo ao criar (pegará o default 'requested')
  final double totalPrice;
  final String originWaypointId;
  final String destinationWaypointId;
  final String? paymentId; // Nulo até ser pago
  final DateTime? createdAt;
  final TripEntity? trip;

  const BookingEntity({
    this.id,
    required this.tripId,
    required this.passengerId,
    required this.driverId,
    this.status,
    required this.totalPrice,
    required this.originWaypointId,
    required this.destinationWaypointId,
    this.paymentId,
    this.createdAt,
    this.trip,
  });

  @override
  List<Object?> get props => [
    id,
    tripId,
    passengerId,
    driverId,
    status,
    totalPrice,
    originWaypointId,
    destinationWaypointId,
    paymentId,
    createdAt,
    trip,
  ];
}
