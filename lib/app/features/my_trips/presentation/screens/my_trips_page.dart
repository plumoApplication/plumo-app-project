import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/features/payment/presentation/widgets/pix_payment_modal.dart';
import 'package:plumo/app/features/booking/presentation/screens/booking_detail_page.dart';

// Imports dos Cubits
import 'package:plumo/app/features/my_trips/presentation/cubit/my_trips_cubit.dart';
import 'package:plumo/app/features/my_trips/presentation/cubit/my_trips_state.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_state.dart';

// Imports das Entidades
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';

class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Usamos MultiBlocProvider para fornecer AMBOS os Cubits
    return MultiBlocProvider(
      providers: [
        // Cubit da Lista (carrega as viagens)
        BlocProvider(create: (context) => sl<MyTripsCubit>()..fetchMyTrips()),
        // Cubit de Pagamento (gera o link)
        BlocProvider(create: (context) => sl<PaymentCubit>()),
      ],
      child: const _MyTripsView(),
    );
  }
}

class _MyTripsView extends StatelessWidget {
  const _MyTripsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Viagens')),
      // 2. Adicionamos um Listener para o PAGAMENTO
      body: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is PaymentPixCreated) {
            // Se o link foi gerado, abre o navegador!
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) =>
                  PixPaymentModal(paymentData: state.paymentData),
            );

            // (Opcional: Resetar o cubit para limpar o estado)
            context.read<PaymentCubit>().reset();
          }
        },
        // O Builder continua escutando a LISTA (MyTripsCubit)
        child: BlocBuilder<MyTripsCubit, MyTripsState>(
          builder: (context, state) {
            if (state is MyTripsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MyTripsError) {
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<MyTripsCubit>().fetchMyTrips(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: Text('Erro: ${state.message}')),
                  ),
                ),
              );
            }

            if (state is MyTripsSuccess) {
              if (state.bookings.isEmpty) {
                return const Center(child: Text('Nenhuma viagem solicitada.'));
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<MyTripsCubit>().fetchMyTrips(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = state.bookings[index];
                    return _buildBookingCard(context, booking);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingEntity booking) {
    if (booking.trip == null) return const SizedBox.shrink();

    final trip = booking.trip!;
    final originName = trip.originName ?? '?';
    final destinationName = trip.destinationName ?? '?';
    final formattedDate = DateFormat(
      'dd/MM/yyyy, HH:mm',
    ).format(trip.departureTime.toLocal());
    final formattedPrice = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(booking.totalPrice);

    // Verifica o status para decidir a cor e o botão
    final isApproved = booking.status == 'approved';
    final isRequested = booking.status == 'requested';
    final isPaid = booking.status == 'paid';

    Color statusColor = Colors.grey;
    String statusText = booking.status ?? '';

    if (isRequested) {
      statusColor = Colors.orange;
      statusText = 'Pendente (Aguardando Motorista)';
    } else if (isApproved) {
      statusColor = Colors.blue;
      statusText = 'Aprovado (Aguardando Pagamento)';
    } else if (isPaid) {
      statusColor = Colors.green;
      statusText = 'Confirmado / Pago';
    }

    return InkWell(
      onTap: () async {
        // Navega para detalhes e espera resultado (se cancelou)
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BookingDetailPage(booking: booking),
          ),
        );

        // Se retornou 'true' (houve cancelamento/alteração), recarrega a lista
        if (result == true && context.mounted) {
          context.read<MyTripsCubit>().fetchMyTrips();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isApproved
              ? const BorderSide(color: Colors.blue, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rota
              Text(
                '$originName → $destinationName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Data e Preço
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Status e Ação
              Row(
                children: [
                  Expanded(
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // --- BOTÃO DE PAGAR (Só aparece se Aprovado) ---
                  if (isApproved)
                    BlocBuilder<PaymentCubit, PaymentState>(
                      builder: (context, paymentState) {
                        // Se estiver carregando ESTE pagamento específico...
                        // (Nota: Esta lógica simples mostra loading em todos os botões se um estiver pagando.
                        //  Para MVP está ok. Para prod, precisaríamos verificar o ID).
                        if (paymentState is PaymentLoading &&
                            paymentState.bookingId == booking.id) {
                          return const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        return ElevatedButton(
                          onPressed: () {
                            // Chama o Cubit para gerar o link
                            context.read<PaymentCubit>().payWithPix(
                              bookingId: booking.id!,
                              title: 'Viagem para $destinationName',
                              price: booking.totalPrice,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Pagar Agora'),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
