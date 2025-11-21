import 'package:plumo/app/features/booking/data/models/booking_model.dart';

abstract class DriverTripDetailsRemoteDataSource {
  Future<List<BookingModel>> getTripPassengers(String tripId);
}
