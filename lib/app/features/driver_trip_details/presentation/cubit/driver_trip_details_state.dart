import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

abstract class DriverTripDetailsState extends Equatable {
  const DriverTripDetailsState();
  @override
  List<Object> get props => [];
}

class DriverTripDetailsInitial extends DriverTripDetailsState {}

class DriverTripDetailsLoading extends DriverTripDetailsState {}

class DriverTripDetailsLoaded extends DriverTripDetailsState {
  final TripEntity trip;
  final List<BookingEntity> passengers;
  final double estimatedProfit;

  const DriverTripDetailsLoaded({
    required this.trip,
    required this.passengers,
    required this.estimatedProfit,
  });

  @override
  List<Object> get props => [trip, passengers, estimatedProfit];
}

class DriverTripDetailsError extends DriverTripDetailsState {
  final String message;
  const DriverTripDetailsError({required this.message});
  @override
  List<Object> get props => [message];
}
