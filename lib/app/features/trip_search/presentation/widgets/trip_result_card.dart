import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';

class TripResultCard extends StatelessWidget {
  final TripSearchResultEntity trip;
  final VoidCallback onTap;

  const TripResultCard({super.key, required this.trip, required this.onTap});

  // Lógica de Cores baseada na disponibilidade
  Color _getUrgencyColor() {
    if (trip.availableSeats <= 1) return const Color(0xFFE53935); // Vermelho
    if (trip.availableSeats == 2) return const Color(0xFFFB8C00); // Laranja
    return const Color(0xFF43A047); // Verde
  }

  String _getSeatsText() {
    if (trip.availableSeats <= 0) return 'Esgotado';
    if (trip.availableSeats == 1) return 'Última vaga';
    return '${trip.availableSeats} vagas';
  }

  // [ALTERADO]: Agora mostra sempre a cidade de Origem da viagem
  String _getHeaderLocationInfo() {
    return "Saída de ${trip.originName}";
  }

  String _getTimeOnly() {
    return DateFormat('HH:mm').format(trip.departureTime);
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor();
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Barra Lateral de Status
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),

                // 2. Conteúdo do Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Cabeçalho: Horário e Preço (AUMENTADO) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTimeOnly(),
                                  style: const TextStyle(
                                    fontSize: 24, // Aumentado
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E1E1E),
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getHeaderLocationInfo(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            // Preço em destaque
                            Text(
                              currencyFormat.format(trip.price),
                              style: const TextStyle(
                                fontSize: 24, // Aumentado para destaque
                                fontWeight: FontWeight.w900, // Mais grosso
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // --- Timeline (Trajeto Visual) ---
                        _TripTimeline(
                          origin: trip.displayOrigin,
                          destination: trip.displayDestination,
                        ),

                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),

                        // --- Rodapé: Motorista e Vagas (AUMENTADO) ---
                        Row(
                          children: [
                            // Avatar Motorista (Maior)
                            CircleAvatar(
                              radius: 20, // Aumentado de 14 para 20
                              backgroundColor: Colors.grey[200],
                              child: const Icon(
                                Icons.person,
                                size: 24,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Nome e Estrela
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.driverName,
                                    style: const TextStyle(
                                      fontSize: 15, // Aumentado
                                      fontWeight: FontWeight.w700, // Mais peso
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 18,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        trip.driverRating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Badge de Assentos (Maior e mais visível)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: urgencyColor.withAlpha(8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: urgencyColor.withAlpha(77),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.airline_seat_recline_normal,
                                    size: 18,
                                    color: urgencyColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getSeatsText(),
                                    style: TextStyle(
                                      color: urgencyColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13, // Aumentado
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Widget Privado para desenhar a Timeline ---
class _TripTimeline extends StatelessWidget {
  final String origin;
  final String destination;

  const _TripTimeline({required this.origin, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Coluna Gráfica (Bolinhas)
        Column(
          children: [
            _buildDot(filled: false), // Origem (Vazada)
            Container(
              height: 24,
              width: 2, // Linha um pouco mais grossa
              color: Colors.grey[300],
            ),
            _buildDot(filled: true), // Destino (Cheia)
          ],
        ),
        const SizedBox(width: 12),

        // Coluna de Textos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                origin,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Text(
                destination,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot({required bool filled}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: filled ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black, width: 2.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
