import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/features/payment/data/models/payment_response_model.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PixPaymentPage extends StatefulWidget {
  final PaymentResponseModel paymentData;
  final String bookingId;
  final double totalPrice;

  const PixPaymentPage({
    super.key,
    required this.paymentData,
    required this.bookingId,
    required this.totalPrice,
  });

  @override
  State<PixPaymentPage> createState() => _PixPaymentPageState();
}

class _PixPaymentPageState extends State<PixPaymentPage> {
  late final RealtimeChannel _channel;
  bool _isChecking = false; // Controle de loading do botão manual
  late final PaymentCubit _paymentCubit;

  @override
  void initState() {
    super.initState();
    _paymentCubit = context.read<PaymentCubit>();
    _setupRealtime();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PaymentCubit>().startTimer();
      }
    });
  }

  /// Configura o ouvinte automático (Realtime)
  void _setupRealtime() {
    _channel = Supabase.instance.client
        .channel('public:bookings:${widget.bookingId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.bookingId,
          ),
          callback: (payload) {
            final newStatus = payload.newRecord['status'];
            final paymentStatus = payload.newRecord['payment_status'];

            if (newStatus == 'confirmed' || paymentStatus == 'paid') {
              _onSuccess();
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_channel);
    _paymentCubit.close();
    super.dispose();
  }

  /// Ação de Sucesso (Redirecionamento)
  void _onSuccess() {
    if (!mounted) return;

    // Feedback visual antes de fechar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pagamento confirmado! Boa viagem! 🚗'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Retorna 'true' para a tela anterior recarregar
    Navigator.of(context).pop(true);
  }

  /// Ação do Botão "Já fiz o pagamento"
  Future<void> _manualCheck() async {
    setState(() => _isChecking = true);

    // Chama a verificação no Cubit
    final isPaid = await context.read<PaymentCubit>().verifyPixStatus(
      widget.bookingId,
    );

    if (mounted) {
      setState(() => _isChecking = false);

      if (isPaid) {
        _onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pagamento ainda não identificado. Aguarde alguns segundos.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _copyPix() {
    if (widget.paymentData.qrCode != null) {
      Clipboard.setData(ClipboardData(text: widget.paymentData.qrCode!));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Código Pix copiado!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final formattedPrice = currencyFormat.format(widget.totalPrice);

    Uint8List? qrBytes;
    if (widget.paymentData.qrCodeBase64 != null) {
      try {
        qrBytes = base64Decode(widget.paymentData.qrCodeBase64!);
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pagamento via Pix'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove botão de voltar padrão
        backgroundColor: Colors.grey[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(), // Cancela/Fecha
          ),
        ],
      ),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentExpired) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('O tempo para pagamento expirou.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Timer Logic
          String timerText = "10:00";

          if (state is PaymentTimerTick) {
            final m = (state.secondsRemaining / 60).floor().toString().padLeft(
              2,
              '0',
            );
            final s = (state.secondsRemaining % 60).toString().padLeft(2, '0');
            timerText = "$m:$s";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Cabeçalho com Timer Pequeno e Preço Grande
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Expira em $timerText",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Valor Total",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      formattedPrice,
                      style: TextStyle(
                        fontSize: 36, // Bem grande
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[900],
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 2. QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (qrBytes != null)
                        Image.memory(qrBytes, height: 220, fit: BoxFit.contain)
                      else
                        const SizedBox(
                          height: 220,
                          child: Center(child: Text('QR Code indisponível')),
                        ),

                      const SizedBox(height: 20),

                      // Botão Copiar
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _copyPix,
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text("Copiar código Pix"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.teal.shade400),
                            foregroundColor: Colors.teal.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Instruções
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withAlpha(26)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.blue.shade800,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Instruções",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "1. Copie o código acima.",
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "2. Abra o app do seu banco na área Pix.",
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "3. Escolha 'Pix Copia e Cola'.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 4. Botão de Confirmação Manual
                ElevatedButton(
                  onPressed: _isChecking ? null : _manualCheck,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "JÁ FIZ O PAGAMENTO",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                const Center(
                  child: Text(
                    "A confirmação é automática em até 30 segundos.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
