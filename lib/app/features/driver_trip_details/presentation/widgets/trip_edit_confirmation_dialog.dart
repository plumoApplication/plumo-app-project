import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripEditConfirmationDialog extends StatelessWidget {
  final double totalPrice;
  final double pickupFee;
  final String destinationName;
  final List<Map<String, dynamic>>
  waypointsSummary; // [{name: 'X', price: 10.0}]
  final VoidCallback onConfirm;

  const TripEditConfirmationDialog({
    super.key,
    required this.totalPrice,
    required this.pickupFee,
    required this.destinationName,
    required this.waypointsSummary,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return AlertDialog(
      title: const Text("Confirmar Alterações"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Confira os novos valores que serão salvos:",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Tabela de Preços Visual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  // 1. Viagem Completa
                  _buildLineItem(
                    "Viagem Completa ($destinationName)",
                    totalPrice,
                    currencyFormat,
                    isBold: true,
                  ),

                  // 2. Waypoints
                  if (waypointsSummary.isNotEmpty) ...[
                    const Divider(),
                    ...waypointsSummary.map(
                      (wp) => _buildLineItem(
                        "Até ${wp['name']}",
                        wp['price'],
                        currencyFormat,
                      ),
                    ),
                  ],

                  // 3. Taxa de Busca
                  if (pickupFee > 0) ...[
                    const Divider(),
                    _buildLineItem(
                      "Taxa de Busca (Extra)",
                      pickupFee,
                      currencyFormat,
                      color: Colors.green[700],
                      icon: Icons.add_circle_outline,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Fecha dialog
            onConfirm(); // Executa ação
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: const Text("SALVAR", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildLineItem(
    String label,
    double value,
    NumberFormat format, {
    bool isBold = false,
    Color? color,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color ?? Colors.black87),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color ?? Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            format.format(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
