import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';

// Este é o contrato do DOMÍNIO para a feature de Reserva.

abstract class BookingRepository {
  /// Cria uma nova solicitação de reserva (status 'requested').
  /// O passageiro é quem chama isso.
  Future<Either<Failure, void>> createBooking(BookingEntity booking);

  /// Atualiza o status de uma reserva existente.
  /// Usado pelo Motorista (para 'approve'/'deny')
  /// Usado pelo Passageiro (para 'pay', 'cancel')
  Future<Either<Failure, void>> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  });

  Future<Either<Failure, List<BookingEntity>>> getDriverPendingBookings();
}
