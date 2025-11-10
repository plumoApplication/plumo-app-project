import 'package:equatable/equatable.dart';

// Classe base
abstract class TripSearchState extends Equatable {
  const TripSearchState();
  @override
  List<Object> get props => [];
}

/// Estado Inicial: O formulário está pronto.
class TripSearchInitial extends TripSearchState {}

/// Estado de Carregamento: O usuário clicou em "Buscar"
/// (No futuro, estaremos chamando o Supabase).
class TripSearchLoading extends TripSearchState {}

/// Estado de Sucesso: A busca foi concluída (mesmo que 0 resultados).
/// (No futuro, ele carregará a 'List<TripEntity')
class TripSearchSuccess extends TripSearchState {}

/// Estado de Erro: A busca falhou.
class TripSearchError extends TripSearchState {
  final String message;
  const TripSearchError({required this.message});
  @override
  List<Object> get props => [message];
}
