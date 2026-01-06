import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/profile/domain/entities/profile_entity.dart';

class BookingEntity extends Equatable {
  final String? id;
  final String tripId;
  final String passengerId;
  final String driverId;
  final String? status;
  final String? paymentStatus;
  final double totalPrice;

  final String originName;
  final String destinationName;
  final int seats;

  final String? paymentId;
  final DateTime? createdAt;

  final double? pickupLat;
  final double? pickupLng;
  final String? pickupAddress;

  final TripEntity? trip;
  final ProfileEntity? passengerProfile;
  final ProfileEntity? driverProfile;

  final String? message;
  final String? paymentMethod;

  const BookingEntity({
    this.id,
    required this.tripId,
    required this.passengerId,
    required this.driverId,
    this.status,
    this.paymentStatus,
    required this.totalPrice,
    required this.originName,
    required this.destinationName,
    this.seats = 1,
    this.paymentId,
    this.createdAt,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress,
    this.trip,
    this.passengerProfile,
    this.driverProfile,
    this.message,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    id,
    tripId,
    passengerId,
    driverId,
    status,
    paymentStatus,
    totalPrice,
    originName,
    destinationName,
    seats,
    paymentId,
    createdAt,
    pickupLat,
    pickupLng,
    pickupAddress,
    trip,
    passengerProfile,
    driverProfile,
    message,
    paymentMethod,
  ];
}
