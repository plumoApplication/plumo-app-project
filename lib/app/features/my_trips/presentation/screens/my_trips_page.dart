import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/my_trips/presentation/cubit/my_trips_cubit.dart';
import 'package:plumo/app/features/my_trips/presentation/cubit/my_trips_state.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:intl/intl.dart'; // Para formatar a data

class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Fornecemos o 'MyTripsCubit'
    return BlocProvider(
      create: (context) =>
          sl<MyTripsCubit>()
            ..fetchMyTrips(), // 2. Chamamos a busca assim que o Cubit é criado
      child: const _MyTripsView(),
    );
  }
}

class _MyTripsView extends StatelessWidget {
  const _MyTripsView();

  @override
  Widget build(BuildContext context) {
    // 3. O 'BlocBuilder' reconstrói a UI baseada no estado
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens'),
        // (Não precisamos de 'actions' aqui, usaremos o RefreshIndicator)
      ),
      // O 'RefreshIndicator' permite "Puxar para Atualizar"
      body: RefreshIndicator(
        onRefresh: () async {
          // Chama o Cubit para buscar novamente
          context.read<MyTripsCubit>().fetchMyTrips();
        },
        child: BlocBuilder<MyTripsCubit, MyTripsState>(
          builder: (context, state) {
            // --- Estado de Carregamento ---
            if (state is MyTripsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // --- Estado de Erro ---
            if (state is MyTripsError) {
              // Permite 'scroll' mesmo na tela de erro (para o Refresh funcionar)
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Erro ao buscar suas viagens: ${state.message}\n(Puxe para tentar novamente)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              );
            }

            // --- Estado de Sucesso ---
            if (state is MyTripsSuccess) {
              // Se a lista de reservas estiver vazia
              if (state.bookings.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Text('Você ainda não solicitou nenhuma viagem.'),
                    ),
                  ),
                );
              }

              // Se temos reservas, mostramos a lista
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  return _buildBookingCard(context, booking);
                },
              );
            }

            // Estado inicial (não deve acontecer)
            return const Center(child: Text('Inicializando...'));
          },
        ),
      ),
    );
  }

  /// Widget auxiliar para construir o Card de cada Reserva
  Widget _buildBookingCard(BuildContext context, BookingEntity booking) {
    // Graças à nossa refatoração (Passo 25.4),
    // o 'booking.trip' (a viagem completa) já veio do Supabase

    // Fallback (segurança) caso o JOIN falhe
    if (booking.trip == null) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListTile(title: Text('Erro: Dados da viagem indisponíveis.')),
      );
    }

    final trip = booking.trip!;

    // Lemos os campos desnormalizados da viagem
    final originName = trip.originName ?? 'Origem Desconhecida';
    final destinationName = trip.destinationName ?? 'Destino Desconhecido';

    // Formata a data
    final formattedDate = DateFormat(
      'dd/MM/yyyy, HH:mm',
    ).format(trip.departureTime.toLocal());

    // Formata o Preço
    final formattedPrice = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(booking.totalPrice);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ROTA (Origem -> Destino) ---
            Text(
              '$originName → $destinationName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // --- INFORMAÇÕES (Data, Preço) ---
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(formattedDate, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  formattedPrice,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // --- STATUS DA RESERVA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:', style: TextStyle(fontSize: 14)),
                Text(
                  // Capitaliza a primeira letra (ex: 'requested' -> 'Requested')
                  '${booking.status.toString()[0].toUpperCase()}${booking.status.toString().substring(1)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(booking.status),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper para retornar uma cor baseada no status
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'requested':
        return Colors.orange.shade700;
      case 'approved':
        return Colors.blue.shade700;
      case 'paid':
        return Colors.green.shade700;
      case 'denied':
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
