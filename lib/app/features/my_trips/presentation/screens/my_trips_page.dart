import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plumo/app/features/booking/presentation/screens/booking_detail_page.dart';

// Imports dos Cubits
import 'package:plumo/app/features/my_trips/presentation/cubit/my_trips_cubit.dart';
import 'package:plumo/app/features/my_trips/presentation/cubit/my_trips_state.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_cubit.dart';

// Imports das Entidades
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';

class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializa formatação de data em PT-BR
    initializeDateFormatting('pt_BR', null);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<MyTripsCubit>()..fetchMyTrips()),
        BlocProvider(create: (context) => sl<PaymentCubit>()),
      ],
      child: const _MyTripsView(),
    );
  }
}

class _MyTripsView extends StatefulWidget {
  const _MyTripsView();

  @override
  State<_MyTripsView> createState() => _MyTripsViewState();
}

class _MyTripsViewState extends State<_MyTripsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 Abas: Ativas (Confirmadas/Pendentes), Finalizadas, Canceladas
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Minhas Viagens'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Ativas"),
            Tab(text: "Finalizadas"),
            Tab(text: "Canceladas"),
          ],
        ),
      ),
      body: BlocBuilder<MyTripsCubit, MyTripsState>(
        builder: (context, state) {
          if (state is MyTripsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyTripsError) {
            return _buildErrorState(context, state.message);
          }

          if (state is MyTripsSuccess) {
            // Filtragem dos dados para cada aba
            final activeTrips = state.bookings.where((b) {
              final s = b.status ?? '';
              // Inclui pendentes, aprovadas e pagas
              return s == 'pending' ||
                  s == 'requested' ||
                  s == 'approved' ||
                  s == 'cofirmed';
            }).toList();

            final finishedTrips = state.bookings.where((b) {
              return b.status == 'finished'; // Supondo status 'finished'
            }).toList();

            final cancelledTrips = state.bookings.where((b) {
              return b.status == 'cancelled' ||
                  b.status == 'rejected' ||
                  b.status == 'expired';
            }).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildTripList(context, activeTrips, "Nenhuma viagem ativa."),
                _buildTripList(
                  context,
                  finishedTrips,
                  "Nenhuma viagem finalizada.",
                ),
                _buildTripList(
                  context,
                  cancelledTrips,
                  "Nenhuma viagem cancelada.",
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<MyTripsCubit>().fetchMyTrips(),
            child: const Text("Tentar Novamente"),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(
    BuildContext context,
    List<BookingEntity> bookings,
    String emptyMessage,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<MyTripsCubit>().fetchMyTrips(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _MyTripCard(booking: booking);
        },
      ),
    );
  }
}

// --- WIDGET DO CARD DE VIAGEM (Novo Design) ---

class _MyTripCard extends StatelessWidget {
  final BookingEntity booking;

  const _MyTripCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking.trip == null) return const SizedBox.shrink();

    final trip = booking.trip!;
    final displayOrigin = booking.originName;
    final displayDestination = booking.destinationName;

    // Formatação de Data
    final date = trip.departureTime.toLocal();
    final dayStr = DateFormat(
      "EEEE, d 'de' MMMM",
      "pt_BR",
    ).format(date).replaceAll('-feira', '');
    final formattedDate = dayStr.replaceFirst(
      dayStr[0],
      dayStr[0].toUpperCase(),
    );
    final formattedTime = DateFormat("HH:mm").format(date);
    final formattedPrice = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(booking.totalPrice);

    // --- LÓGICA DE STATUS ---
    final tripStatus = booking.status ?? 'pending';
    final payStatus = booking.paymentStatus ?? 'pending';

    Color statusColor;
    String statusLabel;
    bool showPaymentWarning = false;

    if (tripStatus == 'cancelled' || tripStatus == 'expired') {
      statusColor = Colors.red;
      statusLabel = "Cancelada";
    } else if (tripStatus == 'finished') {
      statusColor = Colors.grey;
      statusLabel = "Finalizada";
    } else if (tripStatus == 'approved') {
      if (payStatus == 'approved' ||
          payStatus == 'paid' ||
          payStatus == 'completed') {
        statusColor = Colors.green;
        statusLabel = "Confirmada";
      } else {
        statusColor = Colors.blue;
        statusLabel = "Aprovada";
        showPaymentWarning = true;
      }
    } else {
      statusColor = Colors.orange;
      statusLabel = "Pendente";
    }

    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BookingDetailPage(booking: booking),
          ),
        );
        if (result == true && context.mounted) {
          context.read<MyTripsCubit>().fetchMyTrips();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // [AJUSTE 4] Sombra mais destacada e difusa
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20), // Opacidade levemente maior
              blurRadius: 15, // Mais difuso (blur maior)
              offset: const Offset(0, 5), // Mais deslocado para baixo
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$formattedDate • $formattedTime",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // [AJUSTE 1] Status maior (Padding e Fonte)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // Aumentado
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // BODY (Rota)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle, size: 12, color: Colors.green),
                      Container(
                        width: 2,
                        height: 32,
                        color: Colors.grey[300],
                      ), // Linha aumentada
                      const Icon(
                        Icons.circle,
                        size: 12,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // [AJUSTE 3] Fontes de Origem/Destino maiores
                        Text(
                          displayOrigin,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 20,
                        ), // Espaçamento ajustado para a nova fonte
                        Text(
                          displayDestination,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // [AJUSTE 2] Preço maior e texto "Valor Total"
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formattedPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20, // Fonte bem maior para o valor
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Valor total",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // FOOTER (Alerta de Pagamento)
            if (showPaymentWarning)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(26),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Aguardando pagamento",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Pagar",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.orange,
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
