import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

abstract class DriverTripDetailsRepository {
  /// Busca a lista de passageiros (reservas) para uma viagem específica.
  Future<Either<Failure, List<BookingEntity>>> getTripPassengers(String tripId);
  Future<Either<Failure, void>> updateTrip(TripEntity trip);
}
