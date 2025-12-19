import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';

class TripResultCard extends StatelessWidget {
  final TripSearchResultEntity trip;
  final VoidCallback onTap;

  const TripResultCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat('HH:mm');
    // Limpeza visual (pegar só a cidade)
    final originCity = trip.displayOrigin.split('-').first.trim();
    final destCity = trip.displayDestination.split('-').first.trim();

    // Lógica Visual dos Ícones:
    // Se o nome que estamos mostrando for diferente da Origem Real da Trip, é um Waypoint.
    final bool isStartWaypoint = trip.displayOrigin != trip.originName;
    final bool isEndWaypoint = trip.displayDestination != trip.destinationName;

    final seats = trip.availableSeats;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1. Linha do Trajeto e Horário
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horário e Duração (Simulada para visual)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(trip.departureTime),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // Se quiser mostrar a chegada estimada, precisaria calcular a duração
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Visual do Trajeto (Bolinhas e Linha)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLocationRow(
                          context,
                          text: originCity,
                          // Se for Waypoint usa ícone vazado, se for Origem Real usa círculo cheio
                          icon: isStartWaypoint
                              ? Icons.stop_circle_outlined
                              : Icons.circle,
                          color: isStartWaypoint ? Colors.grey : Colors.black87,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          height: 24,
                          width: 2,
                          color: Colors.grey[300],
                        ),
                        _buildLocationRow(
                          context,
                          text: destCity,
                          // Se for Waypoint usa ícone vazado, se for Destino Final usa Pin colorido
                          icon: isEndWaypoint
                              ? Icons.stop_circle_outlined
                              : Icons.location_on,
                          color: isEndWaypoint
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),

                  // Preço
                  Text(
                    currencyFormat.format(trip.price),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),

              // 2. Rodapé: Motorista e Assentos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Motorista e Nota
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.driverName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                trip.driverRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Assentos Disponíveis (Badge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: seats > 0
                          ? Colors.green.withValues(alpha: 26)
                          : Colors.red.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.airline_seat_recline_normal,
                          size: 16,
                          color: seats > 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$seats vaga${seats != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: seats > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context, {
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
