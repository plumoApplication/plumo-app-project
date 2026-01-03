import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BoardingLocationSheet extends StatelessWidget {
  final String locationName;
  final double latitude;
  final double longitude;

  const BoardingLocationSheet({
    super.key,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  // [LÓGICA INTELIGENTE DE MAPAS]
  Future<void> _openExternalMap() async {
    Uri uri;

    if (Platform.isAndroid) {
      // Android: Esquema 'geo'.
      // O Android vai identificar todos os apps de GPS instalados (Waze, Maps, etc)
      // e perguntar ao usuário qual ele quer usar.
      // O parâmetro ?q=lat,lng(Nome) coloca o pino com o nome do local.
      final encodedName = Uri.encodeComponent(locationName);
      uri = Uri.parse(
        "geo:$latitude,$longitude?q=$latitude,$longitude($encodedName)",
      );
    } else if (Platform.isIOS) {
      // iOS: Esquema oficial da Apple.
      // Abre o Apple Maps nativamente.
      final encodedName = Uri.encodeComponent(locationName);
      uri = Uri.parse(
        "https://maps.apple.com/?ll=$latitude,$longitude&q=$encodedName",
      );
    } else {
      // Fallback (Web ou outros): Link universal do Google Maps
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
      );
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Se falhar o método nativo, tenta o link universal do Google como última opção
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
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Local de Embarque",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                Text(
                  "Chegue com 10 minutos de antecedência.",
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
                    onPressed: _openExternalMap, // Chama nossa nova função
                    icon: const Icon(Icons.map_outlined),
                    label: const Text("Abrir no GPS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
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
