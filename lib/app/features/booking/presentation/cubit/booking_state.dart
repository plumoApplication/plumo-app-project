import 'package:equatable/equatable.dart';

// Classe base
abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object> get props => [];
}

/// Estado Inicial: O usuário ainda não clicou em "Solicitar Reserva".
class BookingInitial extends BookingState {}

/// Estado de Carregamento: O app está enviando a solicitação
/// para o Supabase.
class BookingLoading extends BookingState {}

/// Estado de Sucesso: A solicitação de reserva foi criada com sucesso
/// (status 'requested').
class BookingRequestSuccess extends BookingState {}

/// Estado de Erro: Ocorreu um erro ao tentar criar a solicitação.
class BookingError extends BookingState {
  final String message;
  const BookingError({required this.message});
  @override
  List<Object> get props => [message];
}
