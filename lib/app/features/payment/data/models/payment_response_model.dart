class PaymentResponseModel {
  final int id; // ID do pagamento no Mercado Pago
  final String status; // ex: 'pending', 'approved'
  final String statusDetail; // ex: 'accredited'

  // Dados específicos do PIX
  final String? qrCode; // O código "Copia e Cola"
  final String? qrCodeBase64; // A imagem do QR Code (em texto)
  final String? ticketUrl; // Link externo (caso precise)

  PaymentResponseModel({
    required this.id,
    required this.status,
    required this.statusDetail,
    this.qrCode,
    this.qrCodeBase64,
    this.ticketUrl,
  });

  factory PaymentResponseModel.fromMap(Map<String, dynamic> map) {
    // Os dados do Pix ficam aninhados em 'point_of_interaction' -> 'transaction_data'
    final poi = map['point_of_interaction'];
    final transactionData = poi != null ? poi['transaction_data'] : null;

    return PaymentResponseModel(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      status: map['status'] ?? 'unknown',
      statusDetail: map['status_detail'] ?? 'unknown',
      qrCode: transactionData != null ? transactionData['qr_code'] : null,
      qrCodeBase64: transactionData != null
          ? transactionData['qr_code_base64']
          : null,
      ticketUrl: transactionData != null ? transactionData['ticket_url'] : null,
    );
  }
}
