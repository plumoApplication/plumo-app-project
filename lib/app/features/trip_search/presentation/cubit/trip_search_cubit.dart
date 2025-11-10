import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_state.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'; // Precisamos disso para os tipos

class TripSearchCubit extends Cubit<TripSearchState> {
  // (No futuro, injetaremos o 'TripRepository' aqui)

  TripSearchCubit() : super(TripSearchInitial());

  /// Método chamado pela UI quando o usuário clica em "Buscar"
  Future<void> searchTrips({
    required Place? origin,
    required Place? destination,
    required String date,
  }) async {
    // 1. Emite "Carregando"
    emit(TripSearchLoading());

    // --- LÓGICA "FAKE" (Aguardando a Feature do Motorista) ---
    // Vamos apenas simular uma chamada de rede que demora 1 segundo

    await Future.delayed(const Duration(seconds: 1));

    // (Aqui, no futuro, chamaríamos o repositório)
    // final result = await tripRepository.findTrips(
    //   originLatLng: origin!.latLng!,
    //   destinationLatLng: destination!.latLng!,
    //   date: date,
    // );

    // result.fold(
    //   (failure) => emit(TripSearchError(message: failure.message)),
    //   (trips) => emit(TripSearchSuccess(trips: trips)),
    // );

    // Por enquanto, apenas emitimos Sucesso (com 0 viagens)
    emit(TripSearchSuccess());
  }
}
