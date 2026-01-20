import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_state.dart';
import 'package:plumo/app/features/payment/presentation/screens/credit_card_form_page.dart';
import 'package:plumo/app/features/payment/presentation/screens/pix_payment_page.dart';
import 'package:plumo/app/core/services/service_locator.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String bookingId;
  final String title;
  final double price;

  const PaymentMethodSelector({
    super.key,
    required this.bookingId,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    // Formata o preço para R$ 00,00
    final formattedPrice =
        'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentError) {
          Navigator.pop(context); // Fecha o selector se der erro inicial
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }

        // Se o Pix for gerado com sucesso, abrimos o Modal do Pix
        if (state is PaymentProcessed && state.paymentData.qrCode != null) {
          Navigator.pop(context); // Fecha o selector
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context
                    .read<
                      PaymentCubit
                    >(), // Repassa o Cubit (Timer continua rodando)
                child: PixPaymentPage(
                  paymentData: state.paymentData,
                  bookingId: bookingId,
                  totalPrice: price,
                ),
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle de arrastar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Pagamento',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total a pagar: $formattedPrice',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),

            // --- Opção 1: PIX ---
            _PaymentOptionCard(
              icon: Icons.qr_code_2,
              color: Colors.teal,
              title: 'Pix',
              subtitle: 'Aprovação imediata. Mais rápido.',
              badge: 'Recomendado',
              onTap: () {
                // Dispara o pagamento Pix no Cubit
                context.read<PaymentCubit>().payWithPix(
                  bookingId: bookingId,
                  title: title,
                  price: price,
                );
              },
            ),

            const SizedBox(height: 16),

            // --- Opção 2: Cartão ---
            _PaymentOptionCard(
              icon: Icons.credit_card,
              color: Colors.blueAccent,
              title: 'Cartão de Crédito',
              subtitle: 'Parcele em até 12x',
              onTap: () {
                Navigator.pop(context); // Fecha o selector
                // Abre a tela de Cartão
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) =>
                          sl<PaymentCubit>(), // Repassa o Cubit
                      child: CreditCardFormPage(
                        bookingId: bookingId,
                        title: title,
                        price: price,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Loading Overlay se estiver processando o Pix
            BlocBuilder<PaymentCubit, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoading) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  const _PaymentOptionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.teal.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
