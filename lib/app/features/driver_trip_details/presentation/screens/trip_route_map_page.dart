import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class TripRouteMapPage extends StatefulWidget {
  final TripEntity trip;
  final List<BookingEntity> passengers;

  const TripRouteMapPage({
    super.key,
    required this.trip,
    required this.passengers,
  });

  @override
  State<TripRouteMapPage> createState() => _TripRouteMapPageState();
}

class _TripRouteMapPageState extends State<TripRouteMapPage> {
  // Controller do mapa
  late GoogleMapController _mapController;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMapElements();
  }

  void _setupMapElements() {
    // 1. Marcadores (Origem, Destino e Passageiros)

    // Origem da Viagem
    if (widget.trip.originLat != null && widget.trip.originLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: LatLng(widget.trip.originLat!, widget.trip.originLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: "Origem: ${widget.trip.originName}"),
        ),
      );
    }

    // Destino da Viagem
    if (widget.trip.destinationLat != null &&
        widget.trip.destinationLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('dest'),
          position: LatLng(
            widget.trip.destinationLat!,
            widget.trip.destinationLng!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: "Destino: ${widget.trip.destinationName}",
          ),
        ),
      );
    }

    // Passageiros (Pontos de Embarque)
    for (var passenger in widget.passengers) {
      if (passenger.pickupLat != null && passenger.pickupLat != 0) {
        final name = passenger.passengerProfile?.fullName ?? 'Passageiro';
        _markers.add(
          Marker(
            markerId: MarkerId('p_${passenger.id}'),
            position: LatLng(passenger.pickupLat!, passenger.pickupLng!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(title: "Embarque: $name"),
          ),
        );
      }
    }

    // 2. Linha Reta (Polyline visual simples)
    if (widget.trip.originLat != null && widget.trip.destinationLat != null) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_line'),
          color: Colors.blue,
          width: 4,
          points: [
            LatLng(widget.trip.originLat!, widget.trip.originLng!),
            LatLng(widget.trip.destinationLat!, widget.trip.destinationLng!),
          ],
        ),
      );
    }
  }

  // Abre Google Maps ou Waze externo
  Future<void> _launchExternalGPS() async {
    final lat = widget.trip.destinationLat;
    final lng = widget.trip.destinationLng;
    if (lat == null || lng == null) return;

    // Tenta abrir Google Maps Navegação
    final Uri googleMapsUrl = Uri.parse("google.navigation:q=$lat,$lng");
    // Fallback para link web se não tiver o app
    final Uri webUrl = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // [CORREÇÃO 2] Verifica se o widget ainda está montado antes de usar o context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível abrir o GPS externo")),
      );
    }
  }

  // Helper para calcular os limites e dar zoom automático
  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double minLat = 90.0;
    double minLng = 180.0;
    double maxLat = -90.0;
    double maxLng = -180.0;

    for (final marker in markers) {
      final pos = marker.position;
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trajeto da Viagem"),
        centerTitle: true,
        // Adiciona botão para recentralizar o mapa (Uso prático do controller)
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () {
              if (_markers.isNotEmpty) {
                // [CORREÇÃO 1] Uso explícito do _mapController
                _mapController.animateCamera(
                  CameraUpdate.newLatLngBounds(_calculateBounds(_markers), 50),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.trip.originLat ?? -14.2,
                widget.trip.originLng ?? -51.9,
              ),
              zoom: 5,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;

              // [CORREÇÃO 1] Zoom automático ao iniciar
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_markers.isNotEmpty && mounted) {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngBounds(
                      _calculateBounds(_markers),
                      50,
                    ),
                  );
                }
              });
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled:
                false, // Remove botões padrão para limpar a tela
          ),

          // Botão Flutuante de Ação (GPS Externo)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: FloatingActionButton.extended(
                    heroTag: 'gps_ext',
                    onPressed: _launchExternalGPS,
                    backgroundColor: Colors.blue[800],
                    icon: const Icon(Icons.map_outlined, color: Colors.white),
                    label: const Text(
                      "Abrir GPS Externo",
                      style: TextStyle(color: Colors.white),
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
