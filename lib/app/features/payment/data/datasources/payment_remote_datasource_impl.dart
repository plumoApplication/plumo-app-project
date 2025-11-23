import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:plumo/app/features/payment/data/models/payment_response_model.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  PaymentRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<PaymentResponseModel> processPayment({
    required String bookingId,
    required String description,
    required double amount,
    required String paymentMethodId,
    String? token,
    int? installments,
    String? issuerId,
  }) async {
    try {
      // Precisamos do e-mail do pagador (o usuário logado)
      final userEmail = supabaseClient.auth.currentUser?.email;
      if (userEmail == null) {
        throw ServerException(message: "E-mail não encontrado.");
      }

      // Chama a Edge Function atualizada
      final response = await supabaseClient.functions.invoke(
        'create-payment-preference', // (Mantivemos o nome antigo da função)
        body: {
          'booking_id': bookingId,
          'description': description,
          'transaction_amount': amount,
          'payment_method_id': paymentMethodId, // ex: 'pix'
          'payer_email': userEmail,
          'token': token,
          'installments': installments,
          'issuer_id': issuerId,
        },
      );

      final data = response.data;

      if (data == null || (data is Map && data['error'] != null)) {
        throw ServerException(
          message:
              data?['error'] ?? 'Erro desconhecido ao processar pagamento.',
        );
      }

      // Converte o JSON cru do MP para nosso Modelo
      return PaymentResponseModel.fromMap(data);
    } catch (e) {
      throw ServerException(message: 'Erro no pagamento: ${e.toString()}');
    }
  }
}
