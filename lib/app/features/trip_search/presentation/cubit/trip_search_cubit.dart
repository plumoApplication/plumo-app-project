import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/features/trip_search/domain/repositories/trip_search_repository.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_state.dart';

class TripSearchCubit extends Cubit<TripSearchState> {
  final TripSearchRepository repository;

  TripSearchCubit({required this.repository}) : super(TripSearchInitial());

  Future<void> searchTrips({
    required Place origin,
    required Place destination,
    required DateTime date,
  }) async {
    emit(TripSearchLoading());

    // Validação básica
    if (origin.name == null || destination.name == null) {
      emit(
        const TripSearchError(message: 'Origem e Destino são obrigatórios.'),
      );
      return;
    }

    final result = await repository.searchTrips(
      origin: origin,
      destination: destination,
      date: date,
    );

    result.fold((failure) => emit(TripSearchError(message: failure.message)), (
      trips,
    ) {
      if (trips.isEmpty) {
        emit(TripSearchEmpty());
      } else {
        emit(TripSearchSuccess(trips: trips));
      }
    });
  }

  // Método útil para limpar a busca ao sair da tela de resultados
  void resetSearch() {
    emit(TripSearchInitial());
  }
}
