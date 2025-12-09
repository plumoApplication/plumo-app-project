import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// Retorna um objeto simples com o resultado da seleção
class LocationResult {
  final LatLng coordinates;
  final String? address; // Opcional, caso tenhamos conseguido reverter

  LocationResult({required this.coordinates, this.address});
}

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialPosition;

  const MapLocationPicker({super.key, this.initialPosition});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final Completer<GoogleMapController> _controller = Completer();

  // Posição inicial padrão (Centro do Brasil) caso não tenha GPS
  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(-15.7942, -47.8822),
    zoom: 4,
  );

  LatLng? _currentCenter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// Tenta pegar a posição atual do usuário para iniciar o mapa lá
  Future<void> _determinePosition() async {
    // Se o widget já recebeu uma posição inicial (ex: edição), usa ela
    if (widget.initialPosition != null) {
      setState(() {
        _currentCenter = widget.initialPosition;
        _isLoading = false;
      });
      return;
    }

    // Caso contrário, tenta pegar o GPS atual
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _finishLoadingDefault();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _finishLoadingDefault();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _finishLoadingDefault();
      return;
    }

    // Pega a posição atual
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      _finishLoadingDefault();
    }
  }

  void _finishLoadingDefault() {
    setState(() {
      _currentCenter = _defaultLocation.target;
      _isLoading = false;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _currentCenter = position.target;
  }

  void _confirmSelection() {
    if (_currentCenter != null) {
      // Retorna o resultado para a tela anterior
      Navigator.of(context).pop(
        LocationResult(
          coordinates: _currentCenter!,
          // Aqui poderíamos chamar uma API de Geocoding para pegar o endereço
          // Mas para o MVP, vamos deixar o usuário digitar o nome se quiser
          address: null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione o Local'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          if (!_isLoading && _currentCenter != null)
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentCenter!,
                zoom: 16, // Zoom próximo para precisão
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onCameraMove: _onCameraMove,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              // Removemos marcadores fixos, pois o "pino" será visual no centro
            ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // --- O PINO CENTRAL (FIXO) ---
          const Center(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 40.0,
              ), // Ajuste para a ponta do pino ficar no centro
              child: Icon(Icons.location_on, size: 50, color: Colors.red),
            ),
          ),

          // --- BOTÃO DE CONFIRMAR ---
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Cor primária do app
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CONFIRMAR LOCAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
