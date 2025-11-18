import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/booking/data/models/booking_model.dart';

// Este é o contrato da camada de DADOS.

abstract class BookingRemoteDataSource {
  /// Insere uma nova reserva na tabela 'bookings'.
  /// Lança [ServerException] se falhar.
  Future<void> createBooking(BookingModel booking);

  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  });

  Future<List<BookingModel>> getDriverPendingBookings();
}
