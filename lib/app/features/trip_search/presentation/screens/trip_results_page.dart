import 'package:flutter/material.dart';
import 'package:plumo/app/features/booking/presentation/screens/trip_detail_page.dart';
import 'package:plumo/app/features/trip_search/presentation/models/search_result_item.dart';
import 'package:intl/intl.dart';

class TripResultsPage extends StatelessWidget {
  // --- CAMPO ATUALIZADO ---
  // (Era List<TripEntity> trips)
  final List<SearchResultItem> results;

  const TripResultsPage({
    super.key,
    required this.results, // <-- Agora recebe 'results'
  });
  // --- FIM DA ATUALIZAÇÃO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viagens Encontradas')),
      body: _buildBody(),
    );
  }

  // Widget auxiliar para construir o corpo
  Widget _buildBody() {
    // Se a busca não retornou resultados
    if (results.isEmpty) {
      // <-- Usa 'results'
      return const Center(
        child: Text('Nenhuma viagem encontrada para esta rota e data.'),
      );
    }

    // Se temos resultados, mostramos a lista
    return ListView.builder(
      itemCount: results.length, // <-- Usa 'results'
      itemBuilder: (context, index) {
        final item = results[index]; // <-- Usa 'item'
        return _buildTripCard(context, item);
      },
    );
  }

  /// --- WIDGET AUXILIAR ATUALIZADO ---
  /// Agora ele recebe um 'SearchResultItem'
  Widget _buildTripCard(BuildContext context, SearchResultItem item) {
    // --- LÓGICA ATUALIZADA (Sua Sugestão) ---
    // 1. Pega os nomes da rota do *segmento* (ex: A -> B)
    final originName = item.originWaypoint.placeName;
    final destinationName = item.destinationWaypoint.placeName;

    // 2. Pega o preço *calculado* (ex: Preço de B - Preço de A)
    final price = item.calculatedPrice;
    final formattedPrice = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(price); // Formata para R$ 30,00

    // 3. Pega os dados da viagem *completa* (A -> D)
    final trip = item.fullTrip;
    final formattedDate = DateFormat(
      'dd/MM/yyyy, HH:mm',
    ).format(trip.departureTime.toLocal());
    final intermediateStops = trip.waypoints.length - 2;
    // --- FIM DA LÓGICA ---

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripDetailPage(searchResult: item),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ROTA (ex: A -> B) ---
              Text(
                '$originName → $destinationName', // <-- USA OS NOMES DO SEGMENTO
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // --- PREÇO (ex: R$ 30,00) ---
              Text(
                formattedPrice, // <-- USA O PREÇO CALCULADO
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // (Cor temporária)
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // (Informações da viagem completa)
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
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

              //(Fase Futura): Adicionar botão "Reservar"
            ],
          ),
        ),
      ),
    );
  }
}
