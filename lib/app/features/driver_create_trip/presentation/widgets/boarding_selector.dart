import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/widgets/boarding_map_picker.dart';

class BoardingSelector extends StatelessWidget {
  final String? selectedName;
  final LatLng? referenceLocation; // A cidade onde o mapa vai abrir
  final ValueChanged<Map<String, dynamic>> onLocationSelected;
  final VoidCallback onClear;

  const BoardingSelector({
    super.key,
    this.selectedName,
    required this.referenceLocation,
    required this.onLocationSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ESTADO: JÁ SELECIONADO (Mostra Nome + Editar)
    if (selectedName != null && selectedName!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50], // Um azul bem clarinho pra destacar
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.place, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local de Embarque',
                    style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                  ),
                  Text(
                    selectedName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Botão Editar
            TextButton.icon(
              onPressed: () => _openMap(context),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Editar'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
            // Botão Limpar (Opcional, mas útil)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: onClear,
            ),
          ],
        ),
      );
    }

    // 2. ESTADO: VAZIO (Botão Adicionar)
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: referenceLocation == null
            ? null // Desabilita se não tiver cidade selecionada ainda
            : () => _openMap(context),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('ADICIONAR LOCAL DE EMBARQUE'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.black),
          foregroundColor: Colors.black,
        ),
      ),
    );
  }

  void _openMap(BuildContext context) async {
    if (referenceLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma cidade primeiro!')),
      );
      return;
    }

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
