class AddressFormatter {
  /// Limpa o endereço para exibição (Remove CEP e País)
  /// Entrada: "Natal, RN, 59000-000, Brasil"
  /// Saída: "Natal, RN"
  static String format(String address) {
    // Divide por vírgula
    List<String> parts = address.split(',');

    // Remove partes que parecem CEP (contém números e traço) ou "Brasil"
    parts.removeWhere((part) {
      final p = part.trim();
      // Remove "Brasil"
      if (p.toLowerCase() == 'brasil' || p.toLowerCase() == 'brazil') {
        return true;
      }
      // Remove CEP (ex: 59000-000 ou 59000)
      if (RegExp(r'[0-9]{5}-?[0-9]{0,3}').hasMatch(p)) return true;
      return false;
    });

    // Reconstroi a string
    return parts.join(',').trim();
  }
}
