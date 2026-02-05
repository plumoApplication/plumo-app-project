import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/features/booking/presentation/screens/trip_detail_page.dart';
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';
import 'package:plumo/app/features/trip_search/presentation/widgets/trip_result_card.dart';

class TripResultsPage extends StatelessWidget {
  //Dados da busca para exibir no cabeçalho
  final String originCity;
  final String destinationCity;
  final DateTime searchDate;
  final List<TripSearchResultEntity> trips;

  const TripResultsPage({
    super.key,
    required this.originCity,
    required this.destinationCity,
    required this.searchDate,
    required this.trips,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Fundo levemente cinza
      appBar: AppBar(
        title: const Text(
          'Viagens Encontradas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. Cabeçalho de Resumo
          _buildSearchSummaryHeader(),

          // 2. Lista de Resultados
          Expanded(
            child: trips.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return TripResultCard(
                        trip: trip,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TripDetailPage(trip: trip),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget do Cabeçalho Customizado
  Widget _buildSearchSummaryHeader() {
    final dateString = DateFormat(
      "dd 'de' MMMM 'de' yyyy",
      'pt_BR',
    ).format(searchDate);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha 1: Rota
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.black54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "$originCity ➝ $destinationCity",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 12),
          // Linha 2: Data
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.black54,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                dateString, // Ex: 02 de Fevereiro de 2026
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Nenhuma viagem encontrada",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
