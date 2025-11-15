import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_state.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart';
import 'package:plumo/app/features/trip_search/domain/repositories/trip_search_repository.dart';
import 'package:plumo/app/features/trip_search/presentation/models/search_result_item.dart';
import 'package:intl/intl.dart';
// ---------------------------

class TripSearchCubit extends Cubit<TripSearchState> {
  final TripSearchRepository tripSearchRepository;

  TripSearchCubit({required this.tripSearchRepository})
    : super(TripSearchInitial());

  /// Método chamado pela UI quando o usuário clica em "Buscar"
  Future<void> searchTrips({
    required Place? origin,
    required Place? destination,
    required String dateString,
  }) async {
    emit(TripSearchLoading());

    if (origin == null || destination == null || dateString.isEmpty) {
      emit(
        const TripSearchError(
          message: 'Origem, Destino e Data são obrigatórios.',
        ),
      );
      return;
    }

    DateTime date;
    try {
      date = DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      emit(const TripSearchError(message: 'Formato de data inválido.'));
      return;
    }

    // 1. Chama o repositório (que chama a RPC)
    final result = await tripSearchRepository.searchTrips(
      origin: origin,
      destination: destination,
      date: date,
    );

    // 2. Processa o resultado (a lista de viagens A->D)
    result.fold(
      (failure) => emit(TripSearchError(message: failure.message)),

      // --- LÓGICA DE PROCESSAMENTO (Sua Sugestão) ---
      (trips) {
        final List<SearchResultItem> finalResults = [];

        // Para cada viagem A->D encontrada...
        for (final trip in trips) {
          // Tenta encontrar os waypoints A e B (da busca)
          final TripWaypointEntity? originWaypoint = _findMatchingWaypoint(
            trip.waypoints,
            origin.address!,
          );
          final TripWaypointEntity? destinationWaypoint = _findMatchingWaypoint(
            trip.waypoints,
            destination.address!,
          );

          // Se a viagem contém ambos os pontos (A e B)
          // E a ordem está correta (B vem depois de A)
          if (originWaypoint != null &&
              destinationWaypoint != null &&
              originWaypoint.order < destinationWaypoint.order) {
            // --- CÁLCULO DO PREÇO (Sua Observação) ---
            // Preço do Segmento = Preço(Destino B) - Preço(Origem A)
            final double calculatedPrice =
                destinationWaypoint.price - originWaypoint.price;

            // Adiciona o item processado à lista de resultados
            finalResults.add(
              SearchResultItem(
                fullTrip: trip,
                originWaypoint: originWaypoint,
                destinationWaypoint: destinationWaypoint,
                calculatedPrice: calculatedPrice,
              ),
            );
          }
        }

        // 3. Emite o sucesso com a lista de resultados PROCESSADOS
        emit(TripSearchSuccess(results: finalResults));
      },
      // --- FIM DA LÓGICA DE PROCESSAMENTO ---
    );
  }

  // Metodo para limpar os campos quando volta para a tela após a solicitação de reserva.
  void resetSearch() {
    emit(TripSearchInitial());
  }

  /// Função Helper para encontrar o waypoint na lista
  /// (Compara o endereço do Google Places com o nome no waypoint)
  TripWaypointEntity? _findMatchingWaypoint(
    List<TripWaypointEntity> waypoints,
    String placeAddress,
  ) {
    try {
      // Busca o waypoint cujo 'placeName' (ex: "Av. Paulista, São Paulo...")
      // é igual ao 'address' que o Google Places retornou na busca.
      // (Isso assume que os endereços são idênticos)
      return waypoints.firstWhere((wp) => wp.placeName == placeAddress);
    } catch (e) {
      // Se 'firstWhere' falhar (não encontrar), retorna nulo
      return null;
    }
  }
}
