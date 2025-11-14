import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/trip_search/presentation/models/search_result_item.dart';

abstract class TripSearchState extends Equatable {
  const TripSearchState();
  @override
  List<Object> get props => [];
}

class TripSearchInitial extends TripSearchState {}

class TripSearchLoading extends TripSearchState {}

/// --- ESTADO ATUALIZADO ---
/// Agora ele carrega a lista de 'Resultados de Busca' processados
class TripSearchSuccess extends TripSearchState {
  // (Era List<TripEntity>)
  final List<SearchResultItem> results;

  const TripSearchSuccess({required this.results});

  @override
  List<Object> get props => [results];
}
// --- FIM DA ATUALIZAÇÃO ---

class TripSearchError extends TripSearchState {
  final String message;
  const TripSearchError({required this.message});
  @override
  List<Object> get props => [message];
}
