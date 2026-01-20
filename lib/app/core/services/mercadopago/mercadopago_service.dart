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

    try {
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
        throw ServerException(
          message: 'Não foi possível validar o cartão. Verifique os dados.',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Erro de conexão com Mercado Pago.');
    }
  }

  /// Método auxiliar para detectar a bandeira do cartão (Simples para MVP)
  /// Baseado nos cartões de teste do Mercado Pago.
  String guessPaymentMethodId(String cardNumber) {
    // Remove espaços e caracteres não numéricos
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');

    // Fallback se não tiver digitos suficientes para identificar
    if (clean.length < 6) return 'unknown';

    // 1. AMERICAN EXPRESS (34, 37)
    if (clean.startsWith('34') || clean.startsWith('37')) {
      return 'amex';
    }

    // 2. ELO (Verificação prioritária devido a conflitos com Visa/Master)
    // O cartão de teste Elo é 5067... mas Elo também pode começar com 4011, 4389, etc.
    // BINs comuns da Elo:
    if (clean.startsWith('4011') ||
        clean.startsWith('4312') ||
        clean.startsWith('4389') ||
        clean.startsWith('4514') ||
        clean.startsWith('4576') || // Conflict Visa
        clean.startsWith('5041') ||
        clean.startsWith('5066') ||
        clean.startsWith('5067') || // Teste Elo e Produção
        clean.startsWith('5090') ||
        clean.startsWith('6277') ||
        clean.startsWith('6362') ||
        clean.startsWith('6363') ||
        clean.startsWith('650') ||
        clean.startsWith('651') ||
        clean.startsWith('655')) {
      return 'elo';
    }

    // 3. HIPERCARD (6062, 3841)
    if (clean.startsWith('3841') || clean.startsWith('6062')) {
      return 'hipercard';
    }

    // 4. MASTERCARD
    // Faixa Padrão: 51-55
    // Nova Faixa (2xxx): 2221-2720
    // Teste MP / Maestro: Começa com 50 (exeto o 5067 e 5090 que já pegamos no Elo acima)
    // O cartão de teste Master é 5031...
    int firstTwo = int.tryParse(clean.substring(0, 2)) ?? 0;
    int firstFour = int.tryParse(clean.substring(0, 4)) ?? 0;

    if ((firstTwo >= 50 && firstTwo <= 55) || // Cobre 5031(Teste), 51-55(Prod)
        (firstFour >= 2221 && firstFour <= 2720)) {
      return 'master';
    }

    // 5. VISA
    // Qualquer coisa que começa com 4 e não caiu na regra da Elo
    if (clean.startsWith('4')) {
      return 'visa';
    }

    // Default seguro
    return 'unknown';
  }
}
