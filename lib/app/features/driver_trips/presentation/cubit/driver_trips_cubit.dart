import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/driver_trips/domain/repositories/driver_trips_repository.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_state.dart';

class DriverTripsCubit extends Cubit<DriverTripsState> {
  final DriverTripsRepository driverTripsRepository;

  DriverTripsCubit({required this.driverTripsRepository})
    : super(DriverTripsLoading()); // Começa carregando

  /// Método chamado pela UI para buscar (ou re-buscar) as viagens
  Future<void> fetchMyTrips() async {
    // 1. Garante que estamos no estado de Carregando
    emit(DriverTripsLoading());

    // 2. Chama o repositório
    final result = await driverTripsRepository.getMyTrips();

    // 3. Processa o resultado
    result.fold(
      // 3a. Se deu 'Left' (Falha)
      (failure) => emit(DriverTripsError(message: failure.message)),
      // 3b. Se deu 'Right' (Sucesso)
      (trips) => emit(DriverTripsSuccess(trips: trips)),
    );
  }
}
