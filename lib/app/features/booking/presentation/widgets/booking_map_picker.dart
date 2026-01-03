import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/core/utils/debouncer.dart';

class BookingMapPicker extends StatefulWidget {
  final LatLng initialLocation;
  final String? initialName;

  const BookingMapPicker({
    super.key,
    required this.initialLocation,
    this.initialName,
    required double initialLat,
    required double initialLng,
  });

  @override
  State<BookingMapPicker> createState() => _BookingMapPickerState();
}

class _BookingMapPickerState extends State<BookingMapPicker> {
  final Completer<GoogleMapController> _controller = Completer();
  final _places = sl<places.FlutterGooglePlacesSdk>();
  final _debouncer = Debouncer(milliseconds: 500);
  final _searchController = TextEditingController();

  List<places.AutocompletePrediction> _predictions = [];
  bool _showList = false;
  LatLng? _currentCenter;
  String? _selectedPlaceName;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialLocation;
    if (widget.initialName != null) {
      _searchController.text = widget.initialName!;
    }
  }

  // Busca de locais (Autocomplete)
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _showList = false;
      });
      return;
    }

    _debouncer.run(() async {
      try {
        final centerToCheck = _currentCenter ?? widget.initialLocation;
        final bounds = _calculateBounds(centerToCheck);
        final result = await _places.findAutocompletePredictions(
          query,
          countries: ['BR'],
          locationRestriction: bounds,
        );
        if (!mounted) return;
        setState(() {
          _predictions = result.predictions;
          _showList = true;
        });
      } catch (e) {
        debugPrint('Erro busca: $e');
      }
    });
  }

  Future<void> _onPredictionSelected(
    places.AutocompletePrediction prediction,
  ) async {
    try {
      final details = await _places.fetchPlace(
        prediction.placeId,
        fields: [places.PlaceField.Location, places.PlaceField.Name],
      );

      if (!mounted) return;
      if (details.place?.latLng == null) return;

      final lat = details.place!.latLng!.lat;
      final lng = details.place!.latLng!.lng;
      final newPos = LatLng(lat, lng);

      // Move a câmera para o local
      final GoogleMapController controller = await _controller.future;
      if (!mounted) return;
      controller.animateCamera(CameraUpdate.newLatLngZoom(newPos, 16));

      setState(() {
        _searchController.text = prediction.primaryText;
        _selectedPlaceName = prediction.primaryText;
        _predictions = [];
        _showList = false;
        // O _currentCenter será atualizado pelo onCameraMove
      });
      FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint('Erro ao selecionar: $e');
    }
  }

  places.LatLngBounds _calculateBounds(LatLng center) {
    const double offset = 0.1;

    return places.LatLngBounds(
      southwest: places.LatLng(
        lat: center.latitude - offset,
        lng: center.longitude - offset,
      ),
      northeast: places.LatLng(
        lat: center.latitude + offset,
        lng: center.longitude + offset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. O MAPA
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onCameraMove: (position) {
              _currentCenter = position.target;
            },
          ),

          // 2. O PIN CENTRAL
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Icon(Icons.location_on, size: 45, color: Colors.black),
            ),
          ),

          // 3. BARRA DE BUSCA
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(blurRadius: 10, color: Colors.black12),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Buscar local de embarque...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                    ],
                  ),
                ),
                // Lista de Sugestões
                if (_showList)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _predictions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _predictions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.place, color: Colors.grey),
                          title: Text(item.primaryText),
                          subtitle: Text(item.secondaryText),
                          onTap: () => _onPredictionSelected(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // 4. BOTÃO CONFIRMAR
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                final name = _selectedPlaceName ?? _searchController.text;
                final finalName = name.isEmpty
                    ? "Local Selecionado no Mapa"
                    : name;

                Navigator.pop(context, {
                  'name': finalName,
                  'coords': _currentCenter,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'CONFIRMAR LOCAL DE BUSCA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
