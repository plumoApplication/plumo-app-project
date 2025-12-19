import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';

abstract class TripSearchState extends Equatable {
  const TripSearchState();

  @override
  List<Object> get props => [];
}

class TripSearchInitial extends TripSearchState {}

class TripSearchLoading extends TripSearchState {}

class TripSearchSuccess extends TripSearchState {
  final List<TripSearchResultEntity> trips;

  const TripSearchSuccess({required this.trips});

  @override
  List<Object> get props => [trips];
}

class TripSearchEmpty extends TripSearchState {
  // Estado específico para quando a busca não retorna nada
  // Facilita mostrar uma imagem de "Ups, nada por aqui"
}

class TripSearchError extends TripSearchState {
  final String message;

  const TripSearchError({required this.message});

  @override
  List<Object> get props => [message];
}
