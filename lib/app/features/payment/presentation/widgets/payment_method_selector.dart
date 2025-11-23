import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:plumo/app/features/payment/presentation/screens/credit_card_form_page.dart';

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
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Escolha como pagar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Opção 1: PIX
          ListTile(
            leading: const Icon(Icons.qr_code, color: Colors.green, size: 32),
            title: const Text('Pix (Aprovação Imediata)'),
            subtitle: const Text('Seguro e rápido.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context); // Fecha o seletor
              // Chama o método Pix do Cubit que já está na tela pai
              context.read<PaymentCubit>().payWithPix(
                bookingId: bookingId,
                title: title,
                price: price,
              );
            },
          ),
          const Divider(),

          // Opção 2: Cartão de Crédito
          ListTile(
            leading: const Icon(
              Icons.credit_card,
              color: Colors.blue,
              size: 32,
            ),
            title: const Text('Cartão de Crédito'),
            subtitle: const Text('Até 12x.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context); // Fecha o seletor

              // Abre a tela de formulário de cartão
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => CreditCardFormPage(
                        bookingId: bookingId,
                        title: title,
                        price: price,
                      ),
                    ),
                  )
                  .then((result) {
                    // Se voltou com sucesso (true), podemos atualizar algo se precisar
                    if (result == true) {
                      // Opcional: Emitir um evento para atualizar a lista
                    }
                  });
            },
          ),
        ],
      ),
    );
  }
}
