import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_state.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_state.dart';
import 'package:plumo/app/features/payment/presentation/widgets/payment_method_selector.dart';
import 'package:plumo/app/features/payment/presentation/widgets/pix_payment_modal.dart';
import 'package:plumo/app/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:plumo/app/features/reviews/presentation/cubit/reviews_state.dart';
import 'package:plumo/app/features/reviews/presentation/widgets/rate_trip_modal.dart';

class BookingDetailPage extends StatelessWidget {
  final BookingEntity booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Fornecemos o BookingCubit (Cancelar) e o PaymentCubit (Pagar)
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<BookingCubit>()),
        BlocProvider(create: (context) => sl<PaymentCubit>()),
        BlocProvider(
          create: (context) =>
              sl<ReviewsCubit>()..checkReviewStatus(booking.id!),
        ),
      ],
      child: _BookingDetailView(booking: booking),
    );
  }
}

class _BookingDetailView extends StatelessWidget {
  final BookingEntity booking;

  const _BookingDetailView({required this.booking});

  @override
  Widget build(BuildContext context) {
    // Dados da Viagem
    final trip = booking.trip!; // Assumimos que veio do JOIN
    final originName = trip.originName ?? '?';
    final destinationName = trip.destinationName ?? '?';
    final dateStr = DateFormat(
      'dd/MM/yyyy, HH:mm',
    ).format(trip.departureTime.toLocal());
    final priceStr = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(booking.totalPrice);

    // Estados
    final isApproved = booking.status == 'approved';
    final isPaid = booking.status == 'paid';
    final isCancelled = booking.status == 'cancelled';

    return MultiBlocListener(
      listeners: [
        // Listener do Cancelamento
        BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingCancellationLoading) {
              // Poderíamos mostrar um dialog de loading
            }
            if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is BookingCancellationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Atualiza a lista na tela anterior e fecha
              // (Nota: Precisaríamos acessar o MyTripsCubit da tela anterior,
              //  mas como usamos push, ele está no context pai. O ideal é retornar true)
              Navigator.of(context).pop(true);
            }
          },
        ),
        // Listener do Pagamento (Copiado da MyTripsPage)
        BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is PaymentProcessed) {
              // Se tem QR Code, é Pix -> Mostra Modal Pix
              if (state.paymentData.qrCode != null) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      PixPaymentModal(paymentData: state.paymentData),
                );
              } else if (state.paymentData.status == 'approved') {
                // Se status é aprovado e não tem QR Code, é Cartão -> Sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pagamento confirmado!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              context.read<PaymentCubit>().reset();
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Reserva')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de Info
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${booking.status!.toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        '$originName → $destinationName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Data: $dateStr'),
                      Text(
                        'Valor: $priceStr',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // --- BOTÃO PAGAR (Se Aprovado) ---
              if (isApproved)
                BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, state) {
                    if (state is PaymentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () {
                        //Abre o Seletor de Método
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context
                                .read<PaymentCubit>(), // Passa o Cubit atual
                            child: PaymentMethodSelector(
                              bookingId: booking.id!,
                              title: 'Viagem para $destinationName',
                              price: booking.totalPrice,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Pagar Agora',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),
              // --- BOTÃO AVALIAR (Se Paga e NÃO avaliada) ---
              if (isPaid)
                BlocBuilder<ReviewsCubit, ReviewsState>(
                  builder: (context, reviewState) {
                    // --- LÓGICA INVERTIDA (Sem Flash) ---

                    // 1. Se ainda não sabemos (Initial) ou está carregando,
                    // NÃO mostre o botão. Espere a resposta.
                    if (reviewState is ReviewsInitial ||
                        reviewState is ReviewsLoading) {
                      return const SizedBox.shrink();
                    }

                    // 2. Se já temos a resposta da verificação
                    if (reviewState is ReviewStatusChecked) {
                      if (reviewState.hasReviewed) {
                        // Já avaliou: Continue escondido
                        return const SizedBox.shrink();
                      }
                      // Não avaliou: Pode mostrar o botão (fall through)
                    }

                    // 3. Se acabou de enviar com sucesso, esconde
                    if (reviewState is ReviewsSuccess) {
                      return const SizedBox.shrink();
                    }

                    // 4. Se chegamos aqui, é seguro mostrar o botão
                    // (Estado é ReviewStatusChecked(false) ou ReviewsError)
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.star_outline),
                        label: const Text('Avaliar Viagem'),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => BlocProvider.value(
                              value: context.read<ReviewsCubit>(),
                              child: RateTripModal(booking: booking),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),

              // --- BOTÃO CANCELAR (Se Ativo) ---
              if (!isCancelled)
                BlocBuilder<BookingCubit, BookingState>(
                  builder: (context, state) {
                    if (state is BookingCancellationLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      );
                    }
                    return OutlinedButton(
                      onPressed: () {
                        // Confirmação
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancelar Reserva?'),
                            content: Text(
                              isPaid
                                  ? 'Faltam mais de 2h para a viagem? Se sim, o valor será estornado.'
                                  : 'Tem certeza que deseja cancelar esta solicitação?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Não'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx); // Fecha dialog
                                  context.read<BookingCubit>().cancelBooking(
                                    booking.id!,
                                  ); // Cancela
                                },
                                child: const Text(
                                  'Sim, Cancelar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar Reserva'),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
