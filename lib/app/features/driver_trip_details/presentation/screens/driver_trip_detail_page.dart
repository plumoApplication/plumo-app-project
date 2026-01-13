import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/cubit/driver_trip_details_cubit.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/cubit/driver_trip_details_state.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/screens/driver_edit_trip_page.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/screens/trip_route_map_page.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/widgets/passenger_card.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/widgets/trip_data_card.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/widgets/trip_financial_header.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/widgets/trip_route_button.dart';

class DriverTripDetailPage extends StatelessWidget {
  final TripEntity trip;

  const DriverTripDetailPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DriverTripDetailsCubit>()..loadTripDetails(trip),
      child: const _DriverTripDetailView(),
    );
  }
}

class _DriverTripDetailView extends StatelessWidget {
  const _DriverTripDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Detalhes da Viagem"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<DriverTripDetailsCubit, DriverTripDetailsState>(
        builder: (context, state) {
          if (state is DriverTripDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DriverTripDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Erro: ${state.message}"),
                  const Text("Por favor, retorne e tente novamente."),
                ],
              ),
            );
          }
          if (state is DriverTripDetailsLoaded) {
            final currentTrip = state.trip;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. CABEÇALHO FINANCEIRO (Widget Extraído)
                        TripFinancialHeader(
                          estimatedProfit: state.estimatedProfit,
                          departureTime: currentTrip.departureTime,
                        ),

                        const SizedBox(height: 24),

                        // 2. [NOVO] DADOS DA VIAGEM (Card com botão de editar)
                        TripDataCard(
                          trip: currentTrip,
                          onEditTap: () {
                            // Navegação para a tela de edição
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<DriverTripDetailsCubit>(),
                                  child: DriverEditTripPage(
                                    trip: currentTrip,
                                    currentPassengers: state.passengers,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // 2. ROTA DA VIAGEM (Título + Botão)
                        const Text(
                          "Rota da Viagem",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TripRouteButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TripRouteMapPage(
                                  trip: currentTrip,
                                  passengers: state.passengers,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // 3. MANIFESTO DE PASSAGEIROS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Passageiros",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${state.passengers.length} confirmados",
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (state.passengers.isEmpty)
                          _buildEmptyState()
                        else
                          ...state.passengers.map(
                            (p) => PassengerCard(booking: p),
                          ),
                      ],
                    ),
                  ),
                ),

                // 4. RODAPÉ DE AÇÃO (Iniciar Viagem)
                _buildActionFooter(context),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Nenhum passageiro confirmado",
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Funcionalidade de Iniciar Viagem em desenvolvimento",
                  ),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "INICIAR VIAGEM",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
