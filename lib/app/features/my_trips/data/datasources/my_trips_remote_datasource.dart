import 'package:plumo/app/features/booking/data/models/booking_model.dart';

// Contrato dos Dados: O que o Supabase "faz"
abstract class MyTripsRemoteDataSource {
  Future<List<BookingModel>> getMyTrips();
  Stream<List<Map<String, dynamic>>> getBookingStream();
}
