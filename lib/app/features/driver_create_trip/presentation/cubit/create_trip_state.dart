import 'package:equatable/equatable.dart';

// Classe base
abstract class CreateTripState extends Equatable {
  const CreateTripState();
  @override
  List<Object> get props => [];
}

/// Estado Inicial: O formulário está pronto para ser preenchido.
class CreateTripInitial extends CreateTripState {}

/// Estado de Carregamento: O usuário clicou em "Salvar Viagem"
/// e estamos enviando os dados para o Supabase.
class CreateTripLoading extends CreateTripState {}

/// Estado de Sucesso: A viagem foi criada com sucesso.
class CreateTripSuccess extends CreateTripState {}

/// Estado de Erro: Ocorreu um erro ao tentar salvar.
class CreateTripError extends CreateTripState {
  final String message;
  const CreateTripError({required this.message});
  @override
  List<Object> get props => [message];
}
