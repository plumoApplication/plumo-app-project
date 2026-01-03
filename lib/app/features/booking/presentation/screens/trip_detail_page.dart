import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_cubit.dart';
// Import da nova tela de confirmação
import 'package:plumo/app/features/booking/presentation/screens/booking_confirmation_page.dart';
import 'package:plumo/app/features/booking/presentation/widgets/boarding_location_sheet.dart';
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';

class TripDetailPage extends StatefulWidget {
  final TripSearchResultEntity trip;

  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  // [LIMPEZA] Removemos o bool _wantDoorToDoor pois a lógica agora é na próxima tela.

  //Alterando o "." para a "," nos valores
  final _currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

  @override
  Widget build(BuildContext context) {
    // Dados da BUSCA do usuário
    final userSearchOrigin = widget.trip.displayOrigin;
    final userSearchDest = widget.trip.displayDestination;

    // Recuperamos a taxa apenas para mostrar como INFORMAÇÃO, se desejar
    final double driverPickupFee = widget.trip.pickupFee;

    // [CORREÇÃO] O preço aqui é sempre o base. O total final é calculado na Confirmação.
    final double basePrice = widget.trip.price;

    return BlocProvider.value(
      value:
          sl<
            BookingCubit
          >(), // Mantemos o provider caso precise de algo no futuro, mas a ação principal mudou
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Detalhes da Viagem"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com o trecho do passageiro
              _buildRouteHeader(userSearchOrigin, userSearchDest),

              const SizedBox(height: 16),
              // Card de valores (Informativo)
              _buildPriceAndSeatsInfo(driverPickupFee),

              const SizedBox(height: 24),
              const Text(
                "Itinerário Completo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Veja o trajeto completo do motorista",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Stepper Completo (Agora sem o Switch de porta a porta)
              _buildFullItineraryStepper(
                context,
                userSearchOrigin,
                userSearchDest,
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              _buildDriverInfo(),
              const SizedBox(height: 100),
            ],
          ),
        ),
        // Bottom Bar agora apenas mostra o preço base e navega
        bottomSheet: _buildBottomActionParams(context, basePrice),
      ),
    );
  }

  Widget _buildRouteHeader(String origin, String destination) {
    final safeDate = widget.trip.departureTime;
    final dateStr = DateFormat("dd 'de' MMMM", "pt_BR").format(safeDate);
    final timeStr = DateFormat("HH:mm").format(safeDate);
    final weekDay = DateFormat("EEEE", "pt_BR").format(safeDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  origin,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, color: Colors.white70),
              ),
              Flexible(
                child: Text(
                  destination,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, width: 60, color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$weekDay, $dateStr",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 14, color: Colors.white24),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndSeatsInfo(double pickupFee) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Valor por assento",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      _currencyFormat.format(widget.trip.price),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.airline_seat_recline_normal,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${widget.trip.availableSeats} vagas",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Mantemos a informação visual, mas sem interação
            if (pickupFee > 0) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Taxa para realizar o embarque em uma localização especifica de sua escolha: (+ ${_currencyFormat.format(pickupFee)})",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullItineraryStepper(
    BuildContext context,
    String userOrigin,
    String userDest,
  ) {
    final List<Map<String, dynamic>> allStops = [];

    allStops.add({'name': widget.trip.originName, 'type': 'origin'});

    for (var wp in widget.trip.waypoints) {
      allStops.add({'name': wp.placeName, 'type': 'waypoint'});
    }

    allStops.add({'name': widget.trip.destinationName, 'type': 'destination'});

    return Column(
      children: List.generate(allStops.length, (index) {
        final stop = allStops[index];
        final String stopName = stop['name'];
        final bool isLast = index == allStops.length - 1;

        final bool isUserBoarding =
            stopName.toLowerCase().contains(userOrigin.toLowerCase()) ||
            userOrigin.toLowerCase().contains(stopName.toLowerCase());

        final bool isUserDropoff =
            stopName.toLowerCase().contains(userDest.toLowerCase()) ||
            userDest.toLowerCase().contains(stopName.toLowerCase());

        final bool isActive = isUserBoarding || isUserDropoff;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: _buildStepperIcon(
                        isUserBoarding,
                        isUserDropoff,
                        isActive,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(width: 2, color: Colors.grey[300]),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUserBoarding)
                      _buildHighlightLabel("Embarque em:", Colors.blue),
                    if (isUserDropoff)
                      _buildHighlightLabel("Desembarque em:", Colors.red),

                    Text(
                      stopName,
                      style: TextStyle(
                        fontSize: isActive ? 16 : 14,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive ? Colors.black87 : Colors.grey[500],
                      ),
                    ),

                    // [LIMPEZA] Removemos o Switch de porta a porta daqui.
                    // Mantivemos apenas o botão de ver mapa se for o embarque do usuário.
                    if (isUserBoarding) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _showBoardingLocationModal(context),
                        icon: const Icon(Icons.map, size: 16),
                        label: const Text("Ver local do embarque"),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepperIcon(bool isBoarding, bool isDropoff, bool isActive) {
    if (isBoarding) {
      return const Icon(Icons.circle, size: 16, color: Colors.blue);
    } else if (isDropoff) {
      return const Icon(Icons.location_on, size: 20, color: Colors.red);
    } else {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
      );
    }
  }

  Widget _buildHighlightLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Motorista",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trip.driverName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.trip.driverRating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Motorista verificado Plumo.",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionParams(BuildContext context, double basePrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Valor por assento",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    _currencyFormat.format(basePrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                // [CORREÇÃO] Navegação direta para a tela de Confirmação
                onPressed: () => _goToConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Solicitar Reserva",
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
      ),
    );
  }

  void _goToConfirmation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationPage(trip: widget.trip),
      ),
    );
  }

  void _showBoardingLocationModal(BuildContext context) {
    double targetLat = 0.0;
    double targetLng = 0.0;
    String targetName = "";

    // Tratamento seguro para strings que podem vir nulas
    // Se displayOrigin for nulo (improvável, mas seguro), usa string vazia
    final searchName = (widget.trip.displayOrigin).toLowerCase();

    bool found = false;

    // 1. Verificar Waypoints
    for (var wp in widget.trip.waypoints) {
      // Verifica se o nome do waypoint bate com a busca (tratando nulos no placeName se necessário)
      final placeName = wp.placeName;

      if (placeName.toLowerCase().contains(searchName) ||
          searchName.contains(placeName.toLowerCase())) {
        // Prioridade: Ponto Específico
        if (wp.boardingLat != null && wp.boardingLat != 0.0) {
          targetLat = wp.boardingLat!;
          targetLng = wp.boardingLng!;
          // [CORREÇÃO] Garante que não passa null
          targetName = wp.boardingPlaceName ?? placeName;
          found = true;
        }
        // Fallback: Localização geral
        else if (wp.latitude != 0.0) {
          targetLat = wp.latitude;
          targetLng = wp.longitude;
          targetName = placeName;
          found = true;
        }
        break;
      }
    }

    // 2. Verificar Origem Principal
    if (!found) {
      // Prioridade: Ponto Específico da Origem
      if (widget.trip.boardingLat != null && widget.trip.boardingLat != 0.0) {
        targetLat = widget.trip.boardingLat!;
        targetLng = widget.trip.boardingLng!;

        // [CORREÇÃO DO ERRO 1]
        // Se boardingPlaceName for nulo, tenta originName.
        // Se originName também for nulo, usa "Local de Embarque" como último recurso.
        targetName =
            widget.trip.boardingPlaceName ??
            widget.trip.originName ??
            "Local de Embarque";

        found = true;
      }
      // Fallback: Centro da cidade
      else if (widget.trip.originLat != null && widget.trip.originLat != 0.0) {
        targetLat = widget.trip.originLat!;
        targetLng = widget.trip.originLng!;

        // [CORREÇÃO DO ERRO 2]
        // Se originName for nulo, usa "Origem da Viagem"
        targetName = widget.trip.originName ?? "Origem da Viagem";

        found = true;
      }
    }

    if (!found) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A localização exata não está disponível."),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BoardingLocationSheet(
          locationName: targetName,
          latitude: targetLat,
          longitude: targetLng,
        );
      },
    );
  }
}
