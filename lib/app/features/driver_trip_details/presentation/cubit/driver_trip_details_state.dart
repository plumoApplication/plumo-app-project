import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';

abstract class DriverTripDetailsState extends Equatable {
  const DriverTripDetailsState();
  @override
  List<Object> get props => [];
}

class DriverTripDetailsInitial extends DriverTripDetailsState {}

class DriverTripDetailsLoading extends DriverTripDetailsState {}

class DriverTripDetailsLoaded extends DriverTripDetailsState {
  final List<BookingEntity> passengers;

  const DriverTripDetailsLoaded({required this.passengers});

  @override
  List<Object> get props => [passengers];
}

class DriverTripDetailsError extends DriverTripDetailsState {
  final String message;
  const DriverTripDetailsError({required this.message});
  @override
  List<Object> get props => [message];
}
