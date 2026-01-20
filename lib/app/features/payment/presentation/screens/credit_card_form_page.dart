import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_state.dart';

class CreditCardFormPage extends StatefulWidget {
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
  State<CreditCardFormPage> createState() => _CreditCardFormPageState();
}

class _CreditCardFormPageState extends State<CreditCardFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cpfController = TextEditingController();

  int _installments = 1;

  // Mask Formatters
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
  );
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _cardNumberController.removeListener(_updateCardBrand);
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifique os campos em vermelho.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _currentBrand = 'unknown';

  @override
  void initState() {
    super.initState();
    // Adiciona o ouvinte para detectar a bandeira em tempo real
    _cardNumberController.addListener(_updateCardBrand);
  }

  void _updateCardBrand() {
    final number = _cardNumberController.text;
    // Acessa o serviço através do Cubit (que já está injetado)
    final service = context.read<PaymentCubit>().mercadoPagoService;
    final brand = service.guessPaymentMethodId(number);

    if (brand != _currentBrand) {
      setState(() {
        _currentBrand = brand;
      });
    }
  }

  Widget _getBrandIcon() {
    const double iconHeight = 24.0;

    // Fallback para ícone cinza se for desconhecido
    if (_currentBrand == 'unknown' || _currentBrand.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.credit_card, color: Colors.grey),
      );
    }

    // Retorna a imagem da bandeira
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 8.0,
      ), // Ajuste o padding conforme necessário
      child: Image.asset(
        'assets/images/credit_card_icon/$_currentBrand.png', // Ex: assets/images/visa.png
        height: iconHeight,
        width: 40, // Forçamos uma largura máxima para manter padrão
        fit: BoxFit.contain, // Garante que a logo inteira apareça sem distorcer
        errorBuilder: (context, error, stackTrace) {
          // Se esqueceu de colocar a imagem na pasta, mostra o texto como fallback
          return _getFallbackBadge();
        },
      ),
    );
  }

  // Mantivemos o código antigo aqui como um "plano B" caso a imagem falhe
  Widget _getFallbackBadge() {
    Color color = Colors.grey;
    String text = _currentBrand;

    switch (_currentBrand) {
      case 'visa':
        color = Colors.blue.shade900;
        break;
      case 'master':
        color = Colors.orange.shade800;
        break;
      case 'elo':
        color = Colors.red.shade700;
        break;
      case 'amex':
        color = Colors.green.shade700;
        break;
      case 'hipercard':
        color = Colors.redAccent;
        break;
    }

    return Container(
      width: 40,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(128)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento Seguro')),
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
          if (state is PaymentExpired) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Tempo Esgotado'),
                content: const Text('Sua reserva expirou. Tente novamente.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          if (state is PaymentProcessed) {
            final status = state.paymentData.status;
            if (status == 'approved') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pagamento Aprovado!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(true); // Retorna sucesso
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pagamento recusado: $status'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is PaymentLoading;

          // Timer Display
          String timerText = "";
          if (state is PaymentTimerTick) {
            final m = (state.secondsRemaining / 60).floor().toString().padLeft(
              2,
              '0',
            );
            final s = (state.secondsRemaining % 60).toString().padLeft(2, '0');
            timerText = "$m:$s";
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header com Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: R\$ ${widget.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          if (timerText.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Expira em $timerText',
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Campos do Cartão
                      TextFormField(
                        controller: _cardNumberController,
                        inputFormatters: [_cardMask],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Número do Cartão',
                          prefixIcon: const Icon(Icons.credit_card_outlined),
                          suffixIcon: _getBrandIcon(),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.length < 19)
                            ? 'Número inválido'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Titular',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              inputFormatters: [_expiryMask],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Validade (MM/AA)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  (v!.length < 5) ? 'Inválido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              inputFormatters: [_cvvMask],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.help_outline, size: 20),
                              ),
                              validator: (v) =>
                                  (v!.length < 3) ? 'Inválido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cpfController,
                        inputFormatters: [_cpfMask],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CPF do Titular',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v!.length < 14) ? 'CPF incompleto' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue: _installments,
                        decoration: const InputDecoration(
                          labelText: 'Parcelas',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(12, (i) => i + 1).map((i) {
                          return DropdownMenuItem(
                            value: i,
                            child: Text('${i}x ${i == 1 ? 'sem juros' : ''}'),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _installments = val!),
                      ),
                      const SizedBox(height: 32),

                      // Botão Confirmar
                      ElevatedButton(
                        onPressed: isLoading ? null : _onPay,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Colors.blueAccent.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isLoading ? 'PROCESSANDO...' : 'CONFIRMAR PAGAMENTO',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Pagamento criptografado e seguro',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
