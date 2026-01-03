import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/booking/domain/repositories/booking_repository.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository bookingRepository;
  final AuthCubit authCubit;
  // O AuthCubit pode ser útil se precisarmos pegar o ID do usuário logado aqui dentro,
  // mas idealmente a UI já passa o BookingEntity montado.

  BookingCubit({required this.bookingRepository, required this.authCubit})
    : super(BookingInitial());

  /// Cria uma reserva (Passageiro solicitando)
  Future<void> createBooking({required BookingEntity booking}) async {
    emit(BookingLoading());

    final result = await bookingRepository.createBooking(booking);

    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (_) => emit(BookingSuccess()),
    );
  }

  /// Busca solicitações pendentes (Para o motorista aprovar)
  Future<void> fetchPendingBookings() async {
    emit(BookingLoading());

    final result = await bookingRepository.getDriverPendingBookings();

    result.fold((failure) => emit(BookingError(message: failure.message)), (
      bookings,
    ) {
      if (bookings.isEmpty) {
        emit(BookingEmpty());
      } else {
        emit(DriverBookingsLoaded(bookings: bookings));
      }
    });
  }

  /// Motorista Aceita ou Rejeita
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    // Não emitimos Loading global para não piscar a tela toda,
    // idealmente seria um loading local no card, mas por simplificação:
    emit(BookingLoading());

    final result = await bookingRepository.updateBookingStatus(
      bookingId: bookingId,
      newStatus: newStatus,
    );

    result.fold((failure) => emit(BookingError(message: failure.message)), (_) {
      // Após atualizar, recarrega a lista para sumir com o item ou atualizar o status
      fetchPendingBookings();
    });
  }

  /// Cancelamento (Passageiro ou Motorista)
  Future<void> cancelBooking(String bookingId) async {
    emit(BookingLoading());

    final result = await bookingRepository.cancelBooking(bookingId);

    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (successMessage) => emit(BookingCancelled(message: successMessage)),
    );
  }

  // Reseta o estado para o inicial (útil ao sair da tela)
  void resetState() {
    emit(BookingInitial());
  }
}
