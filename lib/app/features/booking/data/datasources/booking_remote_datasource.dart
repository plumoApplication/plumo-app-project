import 'package:plumo/app/features/booking/data/models/booking_model.dart';

// Este é o contrato da camada de DADOS.

abstract class BookingRemoteDataSource {
  /// Insere uma nova reserva na tabela 'bookings'.
  Future<void> createBooking(BookingModel booking);

  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  });

  Future<List<BookingModel>> getDriverPendingBookings();

  Future<String> cancelBooking(String bookingId);
}
