import 'package:flutter/material.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';

class PassengerCard extends StatelessWidget {
  final BookingEntity booking;

  const PassengerCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final name = booking.passengerProfile?.fullName ?? 'Passageiro';
    final status = booking.status?.toLowerCase() ?? 'unknown';

    Color chipColor = Colors.grey.shade200;
    Color chipText = Colors.black;
    String statusLabel = status.toUpperCase();

    if (status == 'paid') {
      chipColor = Colors.green.shade100;
      chipText = Colors.green.shade800;
      statusLabel = "PAGO";
    } else if (status == 'approved') {
      chipColor = Colors.orange.shade100;
      chipText = Colors.orange.shade800;
      statusLabel = "CONFIRMADO";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (booking.originName.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking.pickupAddress ?? booking.originName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: chipText,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
