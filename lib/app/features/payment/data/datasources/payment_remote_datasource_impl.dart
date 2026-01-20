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
    String? docNumber,
  }) async {
    try {
      // Precisamos do e-mail do pagador (o usuário logado)
      final userEmail = supabaseClient.auth.currentUser?.email;
      if (userEmail == null) {
        throw ServerException(message: "E-mail do usuário não identificado.");
      }

      // Chama a Edge Function
      final response = await supabaseClient.functions.invoke(
        'process-payment',
        body: {
          'booking_id': bookingId,
          'payer_email': userEmail,
          'payment_method_id': paymentMethodId, // ex: 'pix'
          'transaction_amount': amount, // Enviamos, mas o back valida no banco
          'token': token,
          'installments': installments,
          'issuer_id': issuerId,
          'doc_number': docNumber, // Envia o CPF para o backend
        },
      );

      final data = response.data;

      // Tratamento de erro vindo da Edge Function
      if (data == null || (data is Map && data['error'] != null)) {
        throw ServerException(
          message: data?['error'] ?? 'Erro desconhecido ao processar.',
        );
      }

      // Converte o JSON cru do MP para nosso Modelo
      return PaymentResponseModel.fromMap(data);
    } on supabase.FunctionException catch (e) {
      // 1. Mensagem de fallback com o código de status HTTP
      String failureMessage =
          "Falha ao processar pagamento (Erro ${e.status}).";

      // 2. Extração segura do conteúdo de 'details'
      if (e.details != null) {
        if (e.details is Map) {
          // Se o backend retornou JSON (ex: {"error": "Saldo insuficiente"})
          final Map<dynamic, dynamic> errorMap = e.details;

          // Tenta encontrar a mensagem em chaves comuns de APIs
          failureMessage =
              errorMap['message'] ??
              errorMap['error'] ??
              errorMap['description'] ??
              failureMessage; // Mantém o fallback se não achar chave
        } else {
          // Se o backend retornou texto puro (String)
          failureMessage = e.details.toString();
        }
      }

      throw ServerException(message: failureMessage);
    } catch (e) {
      // Erros genéricos de conexão ou Dart
      throw ServerException(message: 'Erro no pagamento: ${e.toString()}');
    }
  }
}
