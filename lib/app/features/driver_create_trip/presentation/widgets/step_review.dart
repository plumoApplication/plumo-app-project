import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_cubit.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_state.dart';

class StepReview extends StatelessWidget {
  const StepReview({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateTripCubit>();
    // Calcula os segmentos dinamicamente
    final segments = cubit.calculateSegmentsSummary();

    return BlocBuilder<CreateTripCubit, CreateTripState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Revisão da Viagem',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // --- CARD DE DADOS GERAIS ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Data',
                        state.finalDepartureDateTime != null
                            ? DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(state.finalDepartureDateTime!)
                            : '-',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.my_location,
                        'Origem',
                        state.originName ?? '-',
                      ),
                      _buildInfoRow(
                        Icons.pin_drop,
                        'Embarque',
                        state.originBoardingName ?? 'Padrão',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.location_on,
                        'Destino',
                        state.destinationName ?? '-',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.event_seat,
                        'Assentos',
                        '${state.availableSeats}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- CARD FINANCEIRO (SEGMENTOS) ---
              const Text(
                'Tabela de Preços (Segmentos)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.blue.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (segments.isEmpty)
                        const Text('Viagem direta (sem paradas).'),

                      ...segments.map(
                        (seg) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_right_alt,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  seg,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (state.pickupFee > 0) ...[
                        const Divider(),
                        Row(
                          children: [
                            const Icon(
                              Icons.add_circle,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Taxa de Busca Específica: + R\$ ${state.pickupFee.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- BOTÃO PUBLICAR ---
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      cubit.submitTrip();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Destaque para ação final
                    ),
                    child: const Text(
                      'CONFIRMAR E PUBLICAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
