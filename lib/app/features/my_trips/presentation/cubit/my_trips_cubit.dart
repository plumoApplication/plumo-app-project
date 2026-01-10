import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/my_trips/domain/repositories/my_trips_repository.dart';
import 'package:plumo/app/features/my_trips/presentation/cubit/my_trips_state.dart';

class MyTripsCubit extends Cubit<MyTripsState> {
  final MyTripsRepository myTripsRepository;

  StreamSubscription? _bookingSubscription;

  MyTripsCubit({required this.myTripsRepository}) : super(MyTripsLoading()) {
    _initRealtime();
  }

  void _initRealtime() {
    _bookingSubscription = myTripsRepository.getBookingStream().listen((_) {
      // Recarrega a lista automaticamente quando houver mudanças
      fetchMyTrips();
    });
  }

  /// Método chamado pela UI para buscar (ou re-buscar) as reservas
  Future<void> fetchMyTrips() async {
    // 1. Garante que estamos no estado de Carregando
    emit(MyTripsLoading());

    // 2. Chama o repositório
    final result = await myTripsRepository.getMyTrips();

    // 3. Processa o resultado
    result.fold(
      // 3a. Se deu 'Left' (Falha)
      (failure) => emit(MyTripsError(message: failure.message)),
      // 3b. Se deu 'Right' (Sucesso)
      (bookings) => emit(MyTripsSuccess(bookings: bookings)),
    );
  }

  @override
  Future<void> close() {
    _bookingSubscription?.cancel(); // [NOVO]
    return super.close();
  }
}
