import 'package:plumo/app/features/payment/data/models/payment_response_model.dart';

abstract class PaymentRemoteDataSource {
  /// Processa um pagamento transparente (Pix).
  Future<PaymentResponseModel> processPayment({
    required String bookingId,
    required String description,
    required double amount,
    required String paymentMethodId, // 'pix' ou 'credit_card'
    String? token,
    int? installments,
    String? issuerId,
    String? docNumber,
  });
}
