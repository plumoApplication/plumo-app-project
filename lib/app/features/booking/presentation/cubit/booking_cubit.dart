import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/booking/domain/repositories/booking_repository.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_state.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';
import 'package:plumo/app/features/trip_search/presentation/models/search_result_item.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository bookingRepository;
  final AuthCubit authCubit; // Injetado para saber quem está logado

  BookingCubit({required this.bookingRepository, required this.authCubit})
    : super(BookingInitial());

  /// Método chamado pela UI quando o passageiro clica em "Solicitar Reserva"
  Future<void> createBookingRequest({
    required SearchResultItem searchResult,
  }) async {
    try {
      // 1. Emite "Carregando"
      emit(BookingLoading());

      // 2. Pega o estado atual do AuthCubit
      final authState = authCubit.state;
      if (authState is! Authenticated) {
        emit(
          const BookingError(
            message: 'Você precisa estar logado para reservar.',
          ),
        );
        return;
      }

      // 3. Monta a Entidade 'BookingEntity'
      final BookingEntity newBooking = BookingEntity(
        // IDs nulos (o banco de dados irá gerá-los)
        id: null,
        createdAt: null,
        status: 'requested', // <-- Nosso status inicial planejado
        paymentId: null,

        // Dados da Viagem (do resultado da busca)
        tripId: searchResult.fullTrip.id!,
        driverId: searchResult.fullTrip.driverId!,
        originWaypointId: searchResult.originWaypoint.id!,
        destinationWaypointId: searchResult.destinationWaypoint.id!,
        totalPrice: searchResult.calculatedPrice,

        // Dados do Passageiro (do AuthCubit)
        passengerId: authState.profile.id,
      );

      // 4. Chama o repositório
      final result = await bookingRepository.createBooking(newBooking);

      // 5. Processa o resultado
      result.fold(
        (failure) => emit(BookingError(message: failure.message)),
        (_) => emit(BookingRequestSuccess()),
      );
    } catch (e) {
      emit(
        BookingError(message: 'Um erro inesperado ocorreu: ${e.toString()}'),
      );
    }
  }
}
