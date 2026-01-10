import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importante para datas em PT-BR
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/screens/driver_trip_detail_page.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_cubit.dart';
import 'package:plumo/app/features/driver_trips/presentation/cubit/driver_trips_state.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_trips/presentation/screens/driver_request_detail_page.dart';

class DriverTripsPage extends StatelessWidget {
  const DriverTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);

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
    return BlocBuilder<DriverTripsCubit, DriverTripsState>(
      builder: (context, state) {
        // Cálculo do badge (contador) de solicitações
        int pendingCount = 0;
        if (state is DriverTripsSuccess) {
          pendingCount = state.pendingRequests.length;
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor:
                Colors.grey[50], // Fundo levemente cinza para destacar os cards
            appBar: AppBar(
              title: const Text('Painel do Motorista'),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<DriverTripsCubit>().fetchMyTrips(),
                ),
              ],
              bottom: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 3,
                tabs: [
                  // Aba 1: Solicitações (com Badge se houver pendências)
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Solicitações"),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              pendingCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Aba 2: Minhas Viagens
                  const Tab(text: "Minhas Viagens"),
                ],
              ),
            ),
            body: Builder(
              builder: (context) {
                if (state is DriverTripsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DriverTripsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<DriverTripsCubit>().fetchMyTrips(),
                          child: const Text("Tentar Novamente"),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DriverTripsSuccess) {
                  return TabBarView(
                    children: [
                      // Conteúdo Aba 1
                      _buildRequestsTab(context, state.pendingRequests),
                      // Conteúdo Aba 2
                      _buildMyTripsTab(context, state.trips),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }

  // --- CONTEÚDO DA ABA 1: SOLICITAÇÕES ---
  Widget _buildRequestsTab(BuildContext context, List<BookingEntity> requests) {
    if (requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        message: "Tudo limpo!\nNenhuma solicitação pendente.",
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<DriverTripsCubit>().fetchMyTrips(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _RequestCard(booking: requests[index]);
        },
      ),
    );
  }

  // --- CONTEÚDO DA ABA 2: MINHAS VIAGENS ---
  Widget _buildMyTripsTab(BuildContext context, List<TripEntity> trips) {
    if (trips.isEmpty) {
      return _buildEmptyState(
        icon: Icons.directions_car_outlined,
        message: "Você ainda não criou nenhuma viagem.",
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<DriverTripsCubit>().fetchMyTrips(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _TripCard(trip: trips[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// COMPONENTE 1: CARD DE SOLICITAÇÃO (Moderno)
// ==========================================
class _RequestCard extends StatelessWidget {
  final BookingEntity booking;

  const _RequestCard({required this.booking});

  // Navega para a tela de detalhes mantendo o Cubit
  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DriverTripsCubit>(),
          child: DriverRequestDetailPage(booking: booking),
        ),
      ),
    );
  }

  // Lógica principal do botão "Aprovar"
  void _handleApprovePress(BuildContext context) {
    final bool hasMessage =
        booking.message != null && booking.message!.isNotEmpty;
    final bool isCustom = booking.isCustomPickup;

    // CENÁRIO 1: ALERTA MÁXIMO (Local Específico + Mensagem)
    if (isCustom || hasMessage) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              const Text("Atenção"),
            ],
          ),
          content: const Text(
            "Esta solicitação possui um local de busca específico e uma mensagem do passageiro.\n\n"
            "Por favor, verifique os detalhes antes de aprovar.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Fecha o dialog
                _navigateToDetails(context); // Vai para detalhes
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                "Verificar Detalhes",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    // CENÁRIO 2: ALERTA PADRÃO (Apenas pergunta)
    else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Confirmar Aprovação"),
          content: const Text(
            "Aconselhamos verificar as informações da solicitação antes de aprovar.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _navigateToDetails(context); // Vai para detalhes
              },
              child: const Text("Verificar Informações"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Aprova imediatamente
                context.read<DriverTripsCubit>().approveRequest(booking.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Solicitação aprovada!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                "Aprovar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return "";

    final diff = DateTime.now().difference(date.toLocal());

    if (diff.inMinutes < 1) {
      return "Agora mesmo";
    } else if (diff.inMinutes < 60) {
      return "Há ${diff.inMinutes} min";
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return "Há $h ${h == 1 ? 'hora' : 'horas'}";
    } else {
      final d = diff.inDays;
      return "Há $d ${d == 1 ? 'dia' : 'dias'}";
    }
  }

  void _handleDenyPress(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Recusar Solicitação"),
        content: const Text(
          "Tem certeza que deseja recusar esta solicitação?\n"
          "Esta ação não pode ser desfeita.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Fecha o dialog
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Fecha o dialog
              // Chama o Cubit para recusar
              context.read<DriverTripsCubit>().denyRequest(booking.id!);
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
            child: const Text("Sim, Recusar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passengerName = booking.passengerProfile?.fullName ?? 'Passageiro';
    final price = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(booking.totalPrice);

    // Trecho solicitado pelo passageiro
    final requestedOrigin = booking.originName;
    final requestedDest = booking.destinationName;
    // Viagem Principal do Motorista
    final mainOrigin = booking.trip?.originName ?? 'Origem';
    final mainDest = booking.trip?.destinationName ?? 'Destino';

    final timeAgo = _getTimeAgo(booking.createdAt);
    final hasCustomPickup = booking.isCustomPickup;

    return InkWell(
      onTap: () => _navigateToDetails(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orange.withAlpha(77),
            width: 1,
          ), // Borda sutil laranja
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header: Passageiro e Preço e Tempo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      passengerName.isNotEmpty
                          ? passengerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          passengerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Solicitou uma reserva",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),

                        if (hasCustomPickup) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withAlpha(26),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.deepPurple.withAlpha(77),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.near_me,
                                  size: 12,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    "Busca em endereço específico",
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 10,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeAgo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
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

            const Divider(height: 1),

            // Body: Rota Solicitada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.alt_route_outlined,
                      size: 22,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                            children: [
                              const TextSpan(text: "De "),
                              TextSpan(
                                text: requestedOrigin,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: " para "),
                              TextSpan(
                                text: requestedDest,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Viagem principal: $mainOrigin → $mainDest",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer: Botões de Ação
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleDenyPress(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Recusar"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleApprovePress(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Aprovar"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// COMPONENTE 2: CARD DE VIAGEM (Profissional)
// ==========================================
class _TripCard extends StatelessWidget {
  final TripEntity trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final date = trip.departureTime;
    final day = DateFormat("dd").format(date);
    final month = DateFormat("MMMM", "pt_BR").format(date).toUpperCase();
    final time = DateFormat("HH:mm").format(date);

    final int intermediateStops = trip.waypoints.length;

    // Lógica de Pluralização
    String stopsText = "Viagem direta";
    if (intermediateStops > 0) {
      stopsText =
          "$intermediateStops ${intermediateStops == 1 ? 'parada' : 'paradas'}";
    }

    // Cores de Status
    Color statusColor;
    String statusText;
    Color statusBg;

    switch (trip.status) {
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = "Em Viagem"; // Texto mais dinâmico que "Em andamento"
        statusBg = Colors.blue.shade50;
        break;
      case 'finished':
        statusColor = Colors.grey;
        statusText = "Concluída"; // Termo mais profissional que "Finalizada"
        statusBg = Colors.grey.shade100;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = "Cancelada";
        statusBg = Colors.red.shade50;
        break;
      case 'scheduled':
      default: // O default cai aqui (Agendada)
        statusColor = Colors.green;
        statusText = "Agendada";
        statusBg = Colors.green.shade50;
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DriverTripDetailPage(trip: trip),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // --- CORPO DO CARD (Dividido em Data e Info) ---
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. COLUNA DE DATA (Com Background Destacado)
                  Container(
                    width: 85,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50, // [COR DE DESTAQUE]
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day,
                          style: const TextStyle(
                            fontSize: 28, // [REQ] Dia 28
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          month,
                          style: const TextStyle(
                            fontSize: 12, // [REQ] Mês 12
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 16, // [REQ] Hora 16
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. CONTEÚDO DA ROTA (Horizontal)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Linha Visual (Bolinhas e Traço)
                          Row(
                            children: [
                              Icon(
                                Icons.radio_button_checked,
                                size: 16,
                                color: Colors.green[700],
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: Colors.grey[300],
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Nomes das Cidades (Horizontal)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  trip.originName ?? 'Origem',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  trip.destinationName ?? 'Destino',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Informação das Paradas (Abaixo da linha)
                          Row(
                            children: [
                              Icon(
                                Icons.alt_route,
                                size: 18,
                                color: Colors.orange[800],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                stopsText, // [LÓGICA SINGULAR/PLURAL APLICADA]
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Assentos Livres (Alinhado à Direita)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.event_seat,
                                    size: 14,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(width: 6),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "${trip.availableSeats}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: " assentos livres",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- RODAPÉ (Status e Ação - Mantido) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withAlpha(51)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 12, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ação
                  Row(
                    children: [
                      Text(
                        "Ver detalhes da viagem",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
