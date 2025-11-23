import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plumo/app/core/constants/api_constants.dart';
import 'package:plumo/app/core/errors/exceptions.dart';

class MercadoPagoService {
  // URL da API de Tokenização
  static const String _baseUrl = 'https://api.mercadopago.com/v1';

  /// Envia os dados sensíveis do cartão para o Mercado Pago
  /// e recebe um TOKEN seguro.
  Future<String> createCardToken({
    required String cardNumber,
    required String cardholderName,
    required String expirationMonth,
    required String expirationYear,
    required String securityCode,
    required String identificationType, // ex: CPF
    required String identificationNumber,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/card_tokens?public_key=${ApiConstants.mercadoPagoPublicKey}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "card_number": cardNumber.replaceAll(' ', ''),
        "cardholder": {
          "name": cardholderName,
          "identification": {
            "type": identificationType,
            "number": identificationNumber,
          },
        },
        "security_code": securityCode,
        "expiration_month": int.parse(expirationMonth),
        "expiration_year": int.parse(expirationYear),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['id']; // Retorna o token (ex: 1234567890abc)
    } else {
      // Tratamento de erro básico
      throw ServerException(
        message: 'Erro ao validar cartão: ${response.body}',
      );
    }
  }

  /// Método auxiliar para detectar a bandeira do cartão (Simples para MVP)
  /// Baseado nos cartões de teste do Mercado Pago.
  String guessPaymentMethodId(String cardNumber) {
    // Remove espaços
    final cleanNumber = cardNumber.replaceAll(' ', '');

    if (cleanNumber.isEmpty) return 'visa'; // Fallback

    if (cleanNumber.startsWith('4')) {
      return 'visa';
    } else if (cleanNumber.startsWith('5')) {
      return 'master';
    } else if (cleanNumber.startsWith('3')) {
      return 'amex';
    } else if (cleanNumber.startsWith('6')) {
      return 'elo'; // Comum no Brasil
    } else if (cleanNumber.startsWith('1')) {
      return 'hipercard'; // Comum no Brasil
    }

    // Default para testes se não reconhecer
    return 'visa';
  }
}
