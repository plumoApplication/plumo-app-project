import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/core/utils/address_formatter.dart';
import 'package:plumo/app/core/utils/debouncer.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_cubit.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_state.dart';

class StepWaypoints extends StatefulWidget {
  const StepWaypoints({super.key});

  @override
  State<StepWaypoints> createState() => _StepWaypointsState();
}

class _StepWaypointsState extends State<StepWaypoints> {
  // Controllers para a NOVA parada sendo criada
  final _placeController = TextEditingController();
  final _priceController = TextEditingController();
  final _boardingController = TextEditingController();

  // Autocomplete
  final _places = sl<places.FlutterGooglePlacesSdk>();
  final _debouncer = Debouncer(milliseconds: 500);
  List<places.AutocompletePrediction> _predictions = [];
  bool _showList = false;

  // Dados temporários da parada
  String? _tempPlaceName;
  String? _tempGoogleId;
  LatLng? _tempCoords;

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
        final result = await _places.findAutocompletePredictions(
          query,
          countries: ['BR'],
        );
        if (!mounted) return;
        setState(() {
          _predictions = result.predictions;
          _showList = true;
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  Future<void> _onPredictionSelected(
    places.AutocompletePrediction prediction,
  ) async {
    try {
      final details = await _places.fetchPlace(
        prediction.placeId,
        fields: [
          places.PlaceField.Location,
          places.PlaceField.Name,
          places.PlaceField.Address,
        ],
      );

      if (details.place?.latLng == null) return;

      final place = details.place!;
      final formattedName = AddressFormatter.format(
        place.address ?? prediction.primaryText,
      );

      setState(() {
        _placeController.text = formattedName;
        _tempPlaceName = formattedName;
        _tempGoogleId = prediction.placeId;
        _tempCoords = LatLng(place.latLng!.lat, place.latLng!.lng);
        _predictions = [];
        _showList = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _addWaypoint(BuildContext context) {
    final cubit = context.read<CreateTripCubit>();
    final state = cubit.state;

    // 1. Validações Básicas de Preenchimento
    if (_tempPlaceName == null || _tempCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma cidade válida')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe um preço válido')));
      return;
    }

    // 2. Cria o Objeto
    final newWaypoint = TripWaypointModel(
      order: state.waypoints.length + 1, // Ordem sequencial
      placeName: _tempPlaceName!,
      placeGoogleId: _tempGoogleId!,
      latitude: _tempCoords!.latitude,
      longitude: _tempCoords!.longitude,
      price: price,
      // Dados opcionais de embarque
      boardingPlaceName: _boardingController.text.isNotEmpty
          ? _boardingController.text
          : null,
      // (Poderíamos adicionar LatLng de embarque aqui também se quiséssemos um mapa para cada ponto)
    );

    // 3. Manda pro Cubit (que vai validar os preços)
    cubit.addWaypoint(newWaypoint);

    // 4. Se não der erro, limpa os campos
    // (O Cubit emite um erro no state.errorMessage se falhar, vamos ouvir isso no BlocListener da tela pai)
    // Por enquanto, limpamos visualmente:
    _placeController.clear();
    _priceController.clear();
    _boardingController.clear();
    setState(() {
      _tempPlaceName = null;
      _tempCoords = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos BlocBuilder para atualizar a lista quando adicionar/remover
    return BlocConsumer<CreateTripCubit, CreateTripState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pontos de Parada (Opcional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Adicione cidades onde você pode parar para pegar passageiros.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // --- FORMULÁRIO DE NOVA PARADA ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // Campo Cidade
                    TextFormField(
                      controller: _placeController,
                      decoration: const InputDecoration(
                        labelText: 'Cidade de Parada',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    if (_showList)
                      Container(
                        color: Colors.white,
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _predictions.length,
                          itemBuilder: (context, index) {
                            final item = _predictions[index];
                            return ListTile(
                              title: Text(item.primaryText),
                              onTap: () => _onPredictionSelected(item),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Preço e Embarque
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Preço até aqui (R\$)',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _boardingController,
                      decoration: const InputDecoration(
                        labelText: 'Local de Embarque (Opcional)',
                        hintText: 'Ex: Posto BR Center',
                        prefixIcon: Icon(Icons.place),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _addWaypoint(context),
                        icon: const Icon(Icons.add),
                        label: const Text('ADICIONAR PARADA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Paradas Adicionadas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // --- LISTA DE PARADAS ---
              if (state.waypoints.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('Nenhuma parada adicionada ainda.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.waypoints.length,
                  itemBuilder: (context, index) {
                    final wp = state.waypoints[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text('${index + 1}'),
                        ),
                        title: Text(wp.placeName),
                        subtitle: Text(
                          'R\$ ${wp.price.toStringAsFixed(2)} • ${wp.boardingPlaceName ?? "Sem local específico"}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<CreateTripCubit>().removeWaypoint(
                              index,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
