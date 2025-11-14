import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
// Importamos o Cubit e o State
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_cubit.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_state.dart';
// Importamos a Entidade
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:intl/intl.dart'; // Para formatar a data

class DriverTripsPage extends StatelessWidget {
  const DriverTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Fornecemos o 'DriverTripsCubit'
    return BlocProvider(
      create: (context) =>
          sl<DriverTripsCubit>()
            ..fetchMyTrips(), // 2. Chamamos a busca assim que o Cubit é criado
      child: const _DriverTripsView(),
    );
  }
}

class _DriverTripsView extends StatelessWidget {
  const _DriverTripsView();

  @override
  Widget build(BuildContext context) {
    // 3. O 'BlocBuilder' reconstrói a UI baseada no estado
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens (Motorista)'),
        // Adiciona um botão de "Atualizar"
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Chama o Cubit para buscar novamente
              context.read<DriverTripsCubit>().fetchMyTrips();
            },
          ),
        ],
      ),
      body: BlocBuilder<DriverTripsCubit, DriverTripsState>(
        builder: (context, state) {
          // --- Estado de Carregamento ---
          if (state is DriverTripsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Estado de Erro ---
          if (state is DriverTripsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Erro ao buscar viagens: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // --- Estado de Sucesso ---
          if (state is DriverTripsSuccess) {
            // Se a lista de viagens estiver vazia
            if (state.trips.isEmpty) {
              return const Center(
                child: Text('Você ainda não criou nenhuma viagem.'),
              );
            }

            // Se temos viagens, mostramos a lista
            return ListView.builder(
              itemCount: state.trips.length,
              itemBuilder: (context, index) {
                final trip = state.trips[index];
                return _buildTripCard(context, trip);
              },
            );
          }

          // Estado inicial (não deve acontecer, pois começamos no Loading)
          return const Center(child: Text('Inicializando...'));
        },
      ),
    );
  }

  /// Widget auxiliar para construir o Card de cada Viagem
  Widget _buildTripCard(BuildContext context, TripEntity trip) {
    final originName = trip.originName ?? 'Origem Desconhecida';
    final destinationName = trip.destinationName ?? 'Destino Desconhecido';

    // --- LÓGICA ADICIONADA (Sua Sugestão) ---
    // Calcula o número de paradas *intermediárias*
    // (Total de waypoints - 2 (Origem e Destino))
    final int intermediateStops = trip.waypoints.length - 2;
    // ----------------------------------------

    // Formata a data (ex: 12/11/2025, 14:30)
    final formattedDate = DateFormat(
      'dd/MM/yyyy, HH:mm',
    ).format(trip.departureTime.toLocal()); // Converte para hora local

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
              maxLines: 2, // Permite 2 linhas para nomes longos
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // --- INFORMAÇÕES (Data, Assentos, Status) ---
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
                const Icon(Icons.event_seat, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${trip.availableSeats} assentos disponíveis',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // --- LINHA ADICIONADA (Sua Sugestão) ---
            Row(
              children: [
                const Icon(
                  Icons.pin_drop_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  // Lógica de exibição: 0, 1, ou N paradas
                  intermediateStops == 0
                      ? 'Viagem direta'
                      : '$intermediateStops parada${intermediateStops > 1 ? 's' : ''} intermediária${intermediateStops > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            // --------------------------------------
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.label, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Status: ${trip.status}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
