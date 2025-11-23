import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/mercadopago/mercadopago_service.dart';
import 'package:plumo/app/features/payment/domain/repositories/payment_repository.dart';
import 'package:plumo/app/features/payment/presentation/cubit/payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository paymentRepository;

  final MercadoPagoService mercadoPagoService;

  PaymentCubit({
    required this.paymentRepository,
    required this.mercadoPagoService,
  }) : super(PaymentInitial());

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
    );

    result.fold(
      (failure) => emit(PaymentError(message: failure.message)),
      (paymentData) => emit(PaymentProcessed(paymentData: paymentData)),
    );
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
      final year = "20${dateParts[1]}"; // Assume século 21 (ex: 25 -> 2025)

      // 2. TOKENIZAÇÃO (Chama o Mercado Pago direto)
      final token = await mercadoPagoService.createCardToken(
        cardNumber: cardNumber,
        cardholderName: cardholderName,
        expirationMonth: month,
        expirationYear: year,
        securityCode: securityCode,
        identificationType: 'CPF',
        identificationNumber: cpf,
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
        issuerId: null, // Opcional
      );

      result.fold(
        (failure) => emit(PaymentError(message: failure.message)),
        (paymentData) => emit(PaymentProcessed(paymentData: paymentData)),
      );
    } catch (e) {
      emit(PaymentError(message: 'Erro no cartão: ${e.toString()}'));
    }
  }

  void reset() {
    emit(PaymentInitial());
  }
}
