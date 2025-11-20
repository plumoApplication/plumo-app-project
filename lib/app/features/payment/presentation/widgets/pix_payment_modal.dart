import 'dart:convert'; // Para decodificar a imagem Base64
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para o Clipboard (Copiar)
import 'package:plumo/app/features/payment/data/models/payment_response_model.dart';

class PixPaymentModal extends StatelessWidget {
  final PaymentResponseModel paymentData;

  const PixPaymentModal({super.key, required this.paymentData});

  void _copyToClipboard(BuildContext context) {
    if (paymentData.qrCode != null) {
      Clipboard.setData(ClipboardData(text: paymentData.qrCode!));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Código Pix copiado!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Decodifica a imagem do QR Code (Base64)
    Uint8List? qrImageBytes;
    if (paymentData.qrCodeBase64 != null) {
      try {
        qrImageBytes = base64Decode(paymentData.qrCodeBase64!);
      } catch (e) {
        print('Erro ao decodificar QR Code: $e');
      }
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário
        children: [
          // --- Título ---
          const Text(
            'Pagamento via Pix',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escaneie o QR Code ou copie o código abaixo para pagar no seu banco.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // --- Imagem do QR Code ---
          if (qrImageBytes != null)
            Image.memory(
              qrImageBytes,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            )
          else
            const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),

          const SizedBox(height: 24),

          // --- Código Copia e Cola ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    paymentData.qrCode ?? 'Erro ao gerar código',
                    style: const TextStyle(fontFamily: 'Monospace'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () => _copyToClipboard(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Botão Fechar ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Já fiz o pagamento'),
            ),
          ),
        ],
      ),
    );
  }
}
