import 'package:plumo/app/features/booking/data/models/booking_model.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

abstract class DriverTripDetailsRemoteDataSource {
  Future<List<BookingModel>> getTripPassengers(String tripId);
  Future<void> updateTrip(TripEntity trip);
}
