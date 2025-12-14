import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Se estiver vazio, retorna "0,00"
    if (newValue.text.isEmpty) {
      return newValue.copyWith(
        text: '0,00',
        selection: const TextSelection.collapsed(offset: 4),
      );
    }

    // Remove tudo que não é dígito
    double value = double.parse(newValue.text.replaceAll(RegExp('[^0-9]'), ''));

    // Divide por 100 para ter os centavos (Ex: 1234 -> 12,34)
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    String newText = formatter.format(value / 100).trim();

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  // Função estática para ajudar a converter "1.234,56" de volta para double (1234.56)
  static double parse(String text) {
    String clean = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }

  static String formatDouble(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    return formatter.format(value).trim();
  }
}
