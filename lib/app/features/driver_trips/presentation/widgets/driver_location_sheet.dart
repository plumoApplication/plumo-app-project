import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverLocationSheet extends StatelessWidget {
  final String title;
  final String locationName;
  final double latitude;
  final double longitude;
  final bool isCustom;

  const DriverLocationSheet({
    super.key,
    required this.title,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.isCustom,
  });

  // [LÓGICA INTELIGENTE DE MAPAS]
  Future<void> _openExternalMap() async {
    Uri uri;

    if (Platform.isAndroid) {
      final encodedName = Uri.encodeComponent(locationName);
      uri = Uri.parse(
        "geo:$latitude,$longitude?q=$latitude,$longitude($encodedName)",
      );
    } else if (Platform.isIOS) {
      final encodedName = Uri.encodeComponent(locationName);
      uri = Uri.parse(
        "https://maps.apple.com/?ll=$latitude,$longitude&q=$encodedName",
      );
    } else {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
      );
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final fallback = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
        );
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Erro ao abrir mapa: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(latitude, longitude);
    // Usamos a cor para diferenciar (Opcional, pode usar sempre azul se preferir)
    final themeColor = isCustom ? Colors.deepPurple : Colors.blueGrey;

    return Container(
      height: 450,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.location_on, color: themeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: latLng,
                    zoom: 16,
                  ),
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('boarding_point'),
                      position: latLng,
                      infoWindow: InfoWindow(title: locationName),
                    ),
                  },
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Texto contextualizado para o motorista
                Text(
                  "Confira o local exato antes de iniciar.",
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openExternalMap,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text("Abrir no GPS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
