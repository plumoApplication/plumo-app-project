import 'package:flutter/material.dart';
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';
import 'package:plumo/app/features/trip_search/presentation/widgets/trip_result_card.dart';
// Importaremos a tela de detalhes de reserva futuramente
// import 'package:plumo/app/features/booking/presentation/screens/trip_detail_page.dart';

class TripResultsPage extends StatelessWidget {
  final List<TripSearchResultEntity> trips;

  const TripResultsPage({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    // Ordena por horário (opcional, já que o banco pode trazer ordenado)
    trips.sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Viagens Encontradas', style: TextStyle(fontSize: 18)),
            Text(
              '${trips.length} opções disponíveis',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];

          return TripResultCard(
            trip: trip,
            onTap: () {
              //Navegar para a tela de Detalhes da Reserva (Feature Booking)
              // Exemplo:
              /*
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip))
              );
              */
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Clicou na viagem de ${trip.driverName}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
