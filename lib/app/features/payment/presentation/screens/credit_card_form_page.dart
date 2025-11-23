import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_state.dart';

class CreditCardFormPage extends StatelessWidget {
  final String bookingId;
  final String title;
  final double price;

  const CreditCardFormPage({
    super.key,
    required this.bookingId,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos o Cubit existente (injetado ou passado)
    // Aqui optamos por fornecer um novo escopo ou usar o global se já estiver lá.
    // Como é uma nova rota (Navigator.push), é mais seguro pegar do SL.
    return BlocProvider(
      create: (context) => sl<PaymentCubit>(),
      child: _CreditCardFormView(
        bookingId: bookingId,
        title: title,
        price: price,
      ),
    );
  }
}

class _CreditCardFormView extends StatefulWidget {
  final String bookingId;
  final String title;
  final double price;

  const _CreditCardFormView({
    required this.bookingId,
    required this.title,
    required this.price,
  });

  @override
  State<_CreditCardFormView> createState() => _CreditCardFormViewState();
}

class _CreditCardFormViewState extends State<_CreditCardFormView> {
  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cpfController = TextEditingController();

  // Parcelas (Default 1)
  int _installments = 1;

  // Máscaras
  final _cardMask = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _expiryMask = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _cvvMask = MaskTextInputFormatter(
    mask: '####',
    filter: {"#": RegExp(r'[0-9]')},
  ); // Até 4 dígitos (Amex)
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  void _onPay() {
    if (_formKey.currentState!.validate()) {
      context.read<PaymentCubit>().payWithCreditCard(
        bookingId: widget.bookingId,
        title: widget.title,
        price: widget.price,
        cardNumber: _cardMask.getUnmaskedText(),
        cardholderName: _nameController.text,
        expirationDate: _expiryController.text,
        securityCode: _cvvController.text,
        cpf: _cpfMask.getUnmaskedText(),
        installments: _installments,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagar com Cartão')),
      body: BlocConsumer<PaymentCubit, PaymentState>(
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
            // Sucesso! O pagamento foi processado.
            // (O status pode ser 'approved' ou 'in_process')
            final status = state.paymentData.status;
            if (status == 'approved') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pagamento Aprovado!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Volta para a tela anterior com sucesso
              Navigator.of(context).pop(true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Status: $status. Verifique com seu banco.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final bool isLoading = state is PaymentLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info do Valor
                      Text(
                        'Valor a pagar: R\$ ${widget.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Número do Cartão
                      TextFormField(
                        controller: _cardNumberController,
                        inputFormatters: [_cardMask],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Número do Cartão',
                          prefixIcon: Icon(Icons.credit_card),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.length < 19)
                            ? 'Inválido'
                            : null, // 16 digitos + espaços
                      ),
                      const SizedBox(height: 16),

                      // Nome (Como no cartão)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome (como no cartão)',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          // Validade (MM/YY)
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              inputFormatters: [_expiryMask],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Validade (MM/AA)',
                                hintText: '12/28',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.length < 5)
                                  ? 'Inválido'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // CVV
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              inputFormatters: [_cvvMask],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.length < 3)
                                  ? 'Inválido'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // CPF do Titular
                      TextFormField(
                        controller: _cpfController,
                        inputFormatters: [_cpfMask],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CPF do Titular',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.length < 14) ? 'Inválido' : null,
                      ),
                      const SizedBox(height: 16),

                      // Dropdown de Parcelas (Simplificado para MVP: 1x a 12x)
                      DropdownButtonFormField<int>(
                        value: _installments,
                        decoration: const InputDecoration(
                          labelText: 'Parcelas',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(12, (index) => index + 1)
                            .map(
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(
                                  '${i}x ${i == 1 ? 'sem juros' : ''}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _installments = val!),
                      ),

                      const SizedBox(height: 32),

                      // Botão Pagar
                      ElevatedButton(
                        onPressed: isLoading ? null : _onPay,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Confirmar Pagamento'),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading Overlay
              if (isLoading)
                Container(
                  color: Colors.black.withAlpha(128),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
