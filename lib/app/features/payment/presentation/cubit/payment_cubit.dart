import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/mercadopago/mercadopago_service.dart';
import 'package:plumo/app/features/payment/domain/repositories/payment_repository.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository paymentRepository;

  final MercadoPagoService mercadoPagoService;

  Timer? _timer;
  // Regra: 10 minutos (600s) visualmente + 2 min de gordura no back
  static const int _paymentTimeoutSeconds = 600;

  PaymentCubit({
    required this.paymentRepository,
    required this.mercadoPagoService,
  }) : super(PaymentInitial());

  void reset() {
    _timer?.cancel();
    emit(PaymentInitial());
  }

  /// Inicia o timer regressivo
  void startTimer() {
    _timer?.cancel();
    int remaining = _paymentTimeoutSeconds;

    // Emite o primeiro tick
    emit(PaymentTimerTick(secondsRemaining: remaining));

    // 3. Inicia o novo timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;

      if (remaining <= 0) {
        timer.cancel();
        emit(PaymentExpired());
      } else {
        // Emite o tick atualizando a UI
        emit(PaymentTimerTick(secondsRemaining: remaining));
      }
    });
  }

  /// Inicia um pagamento via PIX
  Future<void> payWithPix({
    required String bookingId,
    required String title,
    required double price,
  }) async {
    // Emite loading específico para este botão
    emit(PaymentLoading(bookingId: bookingId));

    final result = await paymentRepository.processPayment(
      bookingId: bookingId,
      description: title,
      amount: price,
      paymentMethodId: 'pix',
      // Pix pode opcionalmente enviar CPF, mas no MVP deixaremos null
      // Se quiser enviar, basta pedir o CPF antes.
    );

    result.fold((failure) => emit(PaymentError(message: failure.message)), (
      paymentData,
    ) {
      emit(PaymentProcessed(paymentData: paymentData));
    });
  }

  /// Pagamento via CARTÃO DE CRÉDITO (Com tokenização)
  Future<void> payWithCreditCard({
    required String bookingId,
    required String title,
    required double price,
    // Dados do Cartão para Tokenização
    required String cardNumber,
    required String cardholderName,
    required String expirationDate, // MM/YY
    required String securityCode,
    required String cpf,
    required int installments,
  }) async {
    try {
      emit(PaymentLoading(bookingId: bookingId));

      // 1. Preparar dados da data (MM/YY -> Month/Year)
      final dateParts = expirationDate.split('/');
      if (dateParts.length != 2) throw Exception("Data inválida");
      final month = dateParts[0];
      // Garante ano com 4 dígitos (ex: 28 -> 2028)
      final yearShort = dateParts[1];
      final year = yearShort.length == 2 ? "20$yearShort" : yearShort;

      final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');

      // 2. TOKENIZAÇÃO (Chama o Mercado Pago direto)
      final token = await mercadoPagoService.createCardToken(
        cardNumber: cardNumber,
        cardholderName: cardholderName,
        expirationMonth: month,
        expirationYear: year,
        securityCode: securityCode,
        identificationType: 'CPF',
        identificationNumber: cleanCpf,
      );

      final detectedMethodId = mercadoPagoService.guessPaymentMethodId(
        cardNumber,
      );

      // 3. PROCESSAMENTO (Chama nosso Backend com o Token)
      final result = await paymentRepository.processPayment(
        bookingId: bookingId,
        description: title,
        amount: price,
        paymentMethodId: detectedMethodId,
        token: token, // <-- O Token seguro
        installments: installments,
        docNumber: cleanCpf,
      );

      result.fold(
        (failure) => emit(PaymentError(message: failure.message)),
        (paymentData) => emit(PaymentProcessed(paymentData: paymentData)),
      );
    } catch (e) {
      emit(PaymentError(message: 'Erro: ${e.toString()}'));
    }
  }

  /// Verifica manualmente no banco se o pagamento foi confirmado
  Future<bool> verifyPixStatus(String bookingId) async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('bookings')
          .select('status, payment_status')
          .eq('id', bookingId)
          .single();

      final status = response['status'];
      final paymentStatus = response['payment_status'];

      // Retorna TRUE se estiver confirmado/pago
      if (status == 'confirmed' || paymentStatus == 'paid') {
        emit(
          PaymentProcessed(
            paymentData: (state as PaymentProcessed).paymentData,
          ),
        );
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
