import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_cubit.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_state.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:intl/intl.dart';

class DriverTripsPage extends StatelessWidget {
  const DriverTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DriverTripsCubit>()..fetchMyTrips(),
      child: const _DriverTripsView(),
    );
  }
}

class _DriverTripsView extends StatelessWidget {
  const _DriverTripsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens (Motorista)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DriverTripsCubit>().fetchMyTrips();
            },
          ),
        ],
      ),
      body: BlocBuilder<DriverTripsCubit, DriverTripsState>(
        builder: (context, state) {
          if (state is DriverTripsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DriverTripsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Erro: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (state is DriverTripsSuccess) {
            // Usamos um SingleChildScrollView com Column para mostrar as duas listas
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DriverTripsCubit>().fetchMyTrips();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SEÇÃO 1: SOLICITAÇÕES PENDENTES ---
                    if (state.pendingRequests.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Solicitações Pendentes (${state.pendingRequests.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true, // Importante dentro de Column
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.pendingRequests.length,
                        itemBuilder: (context, index) {
                          final request = state.pendingRequests[index];
                          return _buildRequestCard(context, request);
                        },
                      ),
                      const Divider(height: 32, thickness: 1),
                    ],

                    // --- SEÇÃO 2: MINHAS VIAGENS CRIADAS ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Minhas Viagens Criadas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),

                    if (state.trips.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text('Você ainda não criou viagens.'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.trips.length,
                        itemBuilder: (context, index) {
                          final trip = state.trips[index];
                          return _buildTripCard(context, trip);
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Inicializando...'));
        },
      ),
    );
  }

  // --- WIDGET DE SOLICITAÇÃO (Novo) ---
  Widget _buildRequestCard(BuildContext context, BookingEntity booking) {
    // Dados do passageiro
    final passengerName =
        booking.passengerProfile?.fullName ?? 'Passageiro Desconhecido';

    // (Nota: O 'trip' vem do JOIN que fizemos no DataSource)
    final tripOrigin = booking.trip?.originName ?? '?';
    final tripDest = booking.trip?.destinationName ?? '?';

    final price = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(booking.totalPrice);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.orange.shade50, // Cor de destaque leve
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    passengerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Rota da Viagem: $tripOrigin → $tripDest'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão RECUSAR
                OutlinedButton(
                  onPressed: () {
                    // Chama o Cubit para recusar
                    context.read<DriverTripsCubit>().denyRequest(booking.id!);
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Recusar'),
                ),
                const SizedBox(width: 12),
                // Botão APROVAR
                ElevatedButton(
                  onPressed: () {
                    // Chama o Cubit para aprovar
                    context.read<DriverTripsCubit>().approveRequest(
                      booking.id!,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Aprovar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripEntity trip) {
    final originName = trip.originName ?? 'Origem Desconhecida';
    final destinationName = trip.destinationName ?? 'Destino Desconhecido';
    final int intermediateStops = trip.waypoints.length - 2;
    final formattedDate = DateFormat(
      'dd/MM/yyyy, HH:mm',
    ).format(trip.departureTime.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$originName → $destinationName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
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
            Row(
              children: [
                const Icon(
                  Icons.pin_drop_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  intermediateStops == 0
                      ? 'Viagem direta'
                      : '$intermediateStops parada${intermediateStops > 1 ? 's' : ''} intermediária${intermediateStops > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
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
