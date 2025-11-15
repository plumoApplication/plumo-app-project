import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_cubit.dart';
import 'package:plumo/app/features/trip_search/presentation/models/search_result_item.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_state.dart';
import 'package:intl/intl.dart';

class TripDetailPage extends StatelessWidget {
  // Esta tela recebe o item da busca que o usuário selecionou
  final SearchResultItem searchResult;

  const TripDetailPage({super.key, required this.searchResult});

  @override
  Widget build(BuildContext context) {
    // 1. Fornecemos o 'BookingCubit' para esta tela
    return BlocProvider(
      create: (context) => sl<BookingCubit>(),
      child: _TripDetailView(searchResult: searchResult),
    );
  }
}

class _TripDetailView extends StatelessWidget {
  final SearchResultItem searchResult;

  const _TripDetailView({required this.searchResult});

  // Função chamada pelo botão "Solicitar Reserva"
  void _onRequestBooking(BuildContext context) {
    // Pega o Cubit (fornecido acima) e chama o método
    context.read<BookingCubit>().createBookingRequest(
      searchResult: searchResult,
    );
  }

  @override
  Widget build(BuildContext context) {
    // O Consumer "escuta" o estado do 'BookingCubit'
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is BookingRequestSuccess) {
          // Agenda todas as ações de UI/Navegação para DEPOIS
          // que o 'build' deste estado terminar.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 1. Mostra o SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitação de reserva enviada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );

            // 2. Avisa o Cubit da tela anterior para resetar
            context.read<TripSearchCubit>().resetSearch();

            // 3. Navega de volta (com segurança)
            // (Adicionamos 'mounted' por segurança extra)
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
        }
      },
      builder: (context, state) {
        final bool isLoading = state is BookingLoading;

        // Pega os dados do 'searchResult' para exibir
        final trip = searchResult.fullTrip;
        final origin = searchResult.originWaypoint;
        final destination = searchResult.destinationWaypoint;
        final price = searchResult.calculatedPrice;

        final formattedDate = DateFormat(
          'dd/MM/yyyy, HH:mm',
        ).format(trip.departureTime.toLocal());
        final formattedPrice = NumberFormat.simpleCurrency(
          locale: 'pt_BR',
        ).format(price);

        return Scaffold(
          appBar: AppBar(title: const Text('Detalhes da Viagem')),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- O CARD PRINCIPAL ---
                    Card(
                      elevation: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedPrice,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Rota (Segmento)
                            Text(
                              '${origin.placeName} → ${destination.placeName}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Data
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Assentos
                            Row(
                              children: [
                                const Icon(
                                  Icons.event_seat,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${trip.availableSeats} assentos restantes',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    //(Fase Futura):
                    // Adicionar 'Informações do Motorista'
                    // Adicionar 'Detalhes dos Waypoints' (A->B->C->D)
                    const SizedBox(height: 100), // Espaço para o botão
                  ],
                ),
              ),

              // --- O BOTÃO FLUTUANTE DE SOLICITAÇÃO ---
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => _onRequestBooking(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Solicitar Reserva'),
                  ),
                ),
              ),

              // Camada de Loading (para a solicitação)
              if (isLoading)
                Container(
                  color: Colors.black.withAlpha(128),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
