import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Importamos o MapPicker da outra feature pois é uma tela utilitária/comum
import 'package:plumo/app/features/driver_create_trip/presentation/widgets/boarding_map_picker.dart';

class TripEditBoardingSelector extends StatelessWidget {
  final String? selectedName;
  final LatLng? referenceLocation; // Foco inicial do mapa
  final ValueChanged<Map<String, dynamic>> onLocationSelected;
  final String label; // "Local de Embarque", "Ponto de Parada", etc

  const TripEditBoardingSelector({
    super.key,
    this.selectedName,
    required this.referenceLocation,
    required this.onLocationSelected,
    this.label = 'Local de Embarque',
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedName != null && selectedName!.isNotEmpty;

    return InkWell(
      onTap: () => _openMap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasSelection
                    ? Colors.blue.shade50
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: hasSelection ? Colors.blue : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasSelection ? selectedName! : 'Toque para selecionar',
                    style: TextStyle(
                      fontWeight: hasSelection
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
                      color: hasSelection
                          ? Colors.black87
                          : Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 16, color: Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  void _openMap(BuildContext context) async {
    if (referenceLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização de referência inválida!')),
      );
      return;
    }

    // Reutiliza o picker de mapa existente (infraestrutura)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoardingMapPicker(
          initialLocation: referenceLocation!,
          initialName: selectedName,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      onLocationSelected(result);
    }
  }
}
