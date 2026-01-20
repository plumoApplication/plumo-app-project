import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_cubit.dart';
import 'package:plumo/app/features/driver_trips/presentation/widgets/driver_location_sheet.dart';

class DriverRequestDetailPage extends StatelessWidget {
  final BookingEntity booking;

  const DriverRequestDetailPage({super.key, required this.booking});

  // --- LÓGICA INTELIGENTE DE RECUPERAÇÃO DE LOCAL ---
  void _showPickupLocationModal(BuildContext context) {
    double targetLat = 0.0;
    double targetLng = 0.0;
    String targetName = "";

    // 1. Tenta pegar da RESERVA
    if (booking.pickupLat != null && booking.pickupLat != 0.0) {
      targetLat = booking.pickupLat!;
      targetLng = booking.pickupLng!;
      targetName = booking.pickupAddress ?? booking.originName;
    }
    // 2. FALLBACK: Tenta pegar da TRIP vinculada
    else if (booking.trip != null) {
      final trip = booking.trip!;
      bool foundWaypoint = false;
      final bookingOriginName = booking.originName.toLowerCase().trim();

      if (trip.waypoints.isNotEmpty) {
        for (var wp in trip.waypoints) {
          final wpName = wp.placeName.toLowerCase().trim();
          if (wpName.isNotEmpty && bookingOriginName.contains(wpName)) {
            if (wp.boardingLat != null && wp.boardingLat != 0.0) {
              targetLat = wp.boardingLat!;
              targetLng = wp.boardingLng!;
              targetName = wp.boardingPlaceName ?? wp.placeName;
            } else {
              targetLat = wp.latitude;
              targetLng = wp.longitude;
              targetName = wp.placeName;
            }
            foundWaypoint = true;
            break;
          }
        }
      }

      if (!foundWaypoint) {
        targetLat = trip.originLat ?? 0.0;
        targetLng = trip.originLng ?? 0.0;
        targetName = trip.originName ?? booking.originName;
      }
    }
    // 3. Fallback final
    else {
      targetName = booking.originName;
    }

    if (targetLat == 0.0 || targetLng == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "A localização exata não está disponível para visualização.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final isCustom = booking.isCustomPickup;
    // Título dinâmico para diferenciar no modal
    final String title = isCustom
        ? "Local de Busca Específico"
        : "Ponto de Encontro Padrão";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DriverLocationSheet(
        title: title,
        locationName: targetName,
        latitude: targetLat,
        longitude: targetLng,
        isCustom: isCustom,
      ),
    );
  }

  void _handleDenyPress(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Recusar Solicitação"),
        content: const Text("Tem certeza que deseja recusar esta solicitação?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Fecha Dialog

              // Chama o Cubit
              context.read<DriverTripsCubit>().denyRequest(booking.id!);

              // Fecha a tela de detalhes e volta para a lista
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Solicitação recusada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Recusar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date =
        booking.trip?.departureTime ?? booking.createdAt ?? DateTime.now();
    final dayStr = DateFormat("d 'de' MMMM", "pt_BR").format(date);
    final timeStr = DateFormat("HH:mm").format(date);

    final passengerName = booking.passengerProfile?.fullName ?? 'Passageiro';
    final requestPrice = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(booking.totalPrice);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalhes da Solicitação'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CABEÇALHO
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.orange.shade100,
                          child: Text(
                            passengerName.isNotEmpty
                                ? passengerName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          passengerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "$dayStr às $timeStr",
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),

                  // 2. ROTA
                  _buildSectionTitle("Rota Solicitada"),
                  const SizedBox(height: 16),
                  _buildRouteDisplay(),

                  const SizedBox(height: 32),

                  // 3. LOGÍSTICA DE EMBARQUE
                  _buildSectionTitle("Logística de Embarque"),
                  const SizedBox(height: 16),
                  _buildPickupLocation(context),

                  const SizedBox(height: 32),

                  // 4. PAGAMENTO
                  _buildSectionTitle("Pagamento"),
                  const SizedBox(height: 16),
                  _buildPaymentInfo(requestPrice),

                  // 5. MENSAGEM
                  if (booking.message != null &&
                      booking.message!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildSectionTitle("Mensagem do Passageiro"),
                    const SizedBox(height: 16),
                    _buildMessageBubble(passengerName),
                  ],
                ],
              ),
            ),
          ),

          // 6. RODAPÉ DE AÇÃO
          Container(
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleDenyPress(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Recusar"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<DriverTripsCubit>().approveRequest(
                        booking.id!,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Solicitação aprovada!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text("Aprovar"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildMessageBubble(String passengerName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar pequeno ao lado da mensagem
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),

        // Balão de Chat
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors
                  .grey[100], // Cor de fundo suave (tipo mensagem recebida)
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0), // "Bico" do balão
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do Passageiro
                Text(
                  passengerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.green, // Cor de destaque para o nome
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                // Conteúdo da Mensagem
                Text(
                  booking.message!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteDisplay() {
    final requestedOrigin = booking.originName;
    final requestedDest = booking.destinationName;
    final mainOrigin = booking.trip?.originName ?? '?';
    final mainDest = booking.trip?.destinationName ?? '?';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Icon(Icons.circle, size: 12, color: Colors.black),
                Container(width: 2, height: 30, color: Colors.grey[300]),
                const Icon(Icons.location_on, size: 12, color: Colors.black),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    requestedOrigin,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    requestedDest,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_car, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Viagem Principal: $mainOrigin → $mainDest",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickupLocation(BuildContext context) {
    String displayAddress = "";

    // Lógica para mostrar o texto correto no card (igual ao modal)
    if (booking.pickupAddress != null && booking.pickupAddress!.isNotEmpty) {
      displayAddress = booking.pickupAddress!;
    } else if (booking.trip != null) {
      final bookingOrigin = booking.originName.toLowerCase().trim();
      bool found = false;
      for (var wp in booking.trip!.waypoints) {
        if (bookingOrigin.contains(wp.placeName.toLowerCase().trim())) {
          displayAddress = wp.boardingPlaceName ?? wp.placeName;
          found = true;
          break;
        }
      }
      if (!found) {
        displayAddress = booking.trip?.originName ?? booking.originName;
      }
    } else {
      displayAddress = booking.originName;
    }

    final hasCustomPickup = booking.isCustomPickup;
    final Color themeColor = hasCustomPickup
        ? Colors.deepPurple
        : Colors.blueGrey;
    final String badgeText = hasCustomPickup
        ? "BUSCA EM ENDEREÇO ESPECÍFICO"
        : "BUSCA EM ENDEREÇO PADRÃO";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _showPickupLocationModal(context),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.map, color: themeColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        displayAddress,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                      GestureDetector(
                        onTap: () => _showPickupLocationModal(context),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Ver no mapa",
                            style: TextStyle(
                              fontSize: 12,
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(String price) {
    IconData icon = Icons.payment;
    String method = "PIX";
    if (booking.paymentMethodId == 'credit_card') {
      icon = Icons.credit_card;
      method = "Cartão de Crédito";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Text(
                  "Pagamento pendente",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }
}
