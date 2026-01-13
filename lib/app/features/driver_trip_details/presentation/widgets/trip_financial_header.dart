import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripFinancialHeader extends StatelessWidget {
  final double estimatedProfit;
  final DateTime departureTime;

  const TripFinancialHeader({
    super.key,
    required this.estimatedProfit,
    required this.departureTime,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      "dd 'de' MMMM, HH:mm",
      "pt_BR",
    ).format(departureTime);
    final moneyStr = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(estimatedProfit);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            dateStr.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            moneyStr,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.green,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Lucro estimado",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  "Já descontado 12% de taxa do app",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
