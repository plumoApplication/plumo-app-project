import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/presentation/widgets/map_location_picker.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/core/utils/address_formatter.dart';
import 'package:plumo/app/core/utils/debouncer.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_cubit.dart';

class StepBasicInfo extends StatefulWidget {
  const StepBasicInfo({super.key});

  @override
  State<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends State<StepBasicInfo> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  final _pickupFeeController = TextEditingController(text: '0.00');
  final _boardingController = TextEditingController();

  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  // Usa o alias 'places'
  final _places = sl<places.FlutterGooglePlacesSdk>();
  final _debouncer = Debouncer(milliseconds: 500);

  List<places.AutocompletePrediction> _originPredictions = [];
  List<places.AutocompletePrediction> _destinationPredictions = [];

  bool _showOriginList = false;
  bool _showDestinationList = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<CreateTripCubit>().state;
    if (state.originName != null) _originController.text = state.originName!;
    if (state.destinationName != null) {
      _destinationController.text = state.destinationName!;
    }
    if (state.totalPrice > 0) {
      _priceController.text = state.totalPrice.toString();
    }
    if (state.pickupFee > 0) {
      _pickupFeeController.text = state.pickupFee.toString();
    }
    if (state.originBoardingName != null) {
      _boardingController.text = state.originBoardingName!;
    }

    if (state.departureDate != null) {
      _dateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(state.departureDate!);
    }
    if (state.departureTime != null) {
      _timeController.text = DateFormat('HH:mm').format(state.departureTime!);
    }
  }

  void _onSearchChanged(String query, bool isOrigin) {
    if (query.isEmpty) {
      setState(() {
        if (isOrigin) {
          _originPredictions = [];
          _showOriginList = false;
        } else {
          _destinationPredictions = [];
          _showDestinationList = false;
        }
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
          if (isOrigin) {
            _originPredictions = result.predictions;
            _showOriginList = true;
          } else {
            _destinationPredictions = result.predictions;
            _showDestinationList = true;
          }
        });
      } catch (e) {
        debugPrint('Erro autocomplete: $e');
      }
    });
  }

  Future<void> _onPredictionSelected(
    places.AutocompletePrediction prediction,
    bool isOrigin,
  ) async {
    try {
      final placeDetails = await _places.fetchPlace(
        prediction.placeId,
        fields: [
          places.PlaceField.Address,
          places.PlaceField.Location,
          places.PlaceField.Name,
        ],
      );

      // Verificação de segurança
      if (placeDetails.place == null || placeDetails.place!.latLng == null) {
        return;
      }

      final place = placeDetails.place!;

      // --- CORREÇÃO DO CONFLITO DE TIPOS ---
      // Pegamos lat/lng do pacote Places e criamos um objeto do pacote Google Maps
      final double lat = place.latLng!.lat;
      final double lng = place.latLng!.lng;
      final googleMapsCoords = LatLng(lat, lng);
      // -------------------------------------

      final formattedAddress = AddressFormatter.format(
        place.address ?? prediction.primaryText,
      );

      setState(() {
        if (isOrigin) {
          _originController.text = formattedAddress;
          _originPredictions = [];
          _showOriginList = false;

          context.read<CreateTripCubit>().updateBasicInfo(
            originName: formattedAddress,
            originCoords: googleMapsCoords, // Agora o tipo está correto
          );
        } else {
          _destinationController.text = formattedAddress;
          _destinationPredictions = [];
          _showDestinationList = false;

          context.read<CreateTripCubit>().updateBasicInfo(
            destinationName: formattedAddress,
            destinationCoords: googleMapsCoords, // Agora o tipo está correto
          );
        }
      });
    } catch (e) {
      debugPrint('Erro ao selecionar local: $e');
    }
  }

  Future<void> _openMapPicker(BuildContext context) async {
    // 1. Capturamos o Cubit ANTES de sair da tela (aqui o context é seguro)
    final cubit = context.read<CreateTripCubit>();

    // 2. Abrimos o mapa e esperamos
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(builder: (context) => const MapLocationPicker()),
    );

    // 3. Verificamos se voltou com resultado
    if (result != null) {
      // Atualizamos a UI local (se o widget ainda existir)
      if (mounted) {
        setState(() {
          _boardingController.text = "Local selecionado no Mapa";
        });
      }

      // 4. Usamos a variável 'cubit' capturada lá em cima.
      // Não usamos mais 'context.read', então o erro some!
      cubit.updateBasicInfo(
        originBoardingName: "Local selecionado no Mapa",
        originBoardingCoords: result.coordinates,
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      context.read<CreateTripCubit>().updateBasicInfo(date: picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null && mounted) {
      final now = DateTime.now();
      final timeDate = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      _timeController.text = picked.format(context);
      context.read<CreateTripCubit>().updateBasicInfo(time: timeDate);
    }
  }

  Widget _buildPredictionList(
    List<places.AutocompletePrediction> predictions,
    bool isOrigin,
  ) {
    return Container(
      color: Colors.white,
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(top: 4),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: predictions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = predictions[index];
          return ListTile(
            dense: true,
            title: Text(item.primaryText),
            subtitle: Text(item.secondaryText),
            onTap: () => _onPredictionSelected(item, isOrigin),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateTripCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rota Principal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _originController,
            decoration: const InputDecoration(
              labelText: 'Cidade de Origem',
              prefixIcon: Icon(Icons.my_location),
              border: OutlineInputBorder(),
              helperText: 'Digite para buscar...',
            ),
            onChanged: (v) => _onSearchChanged(v, true),
          ),
          if (_showOriginList && _originPredictions.isNotEmpty)
            _buildPredictionList(_originPredictions, true),

          const SizedBox(height: 16),

          TextFormField(
            controller: _destinationController,
            decoration: const InputDecoration(
              labelText: 'Cidade de Destino',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
              helperText: 'Digite para buscar...',
            ),
            onChanged: (v) => _onSearchChanged(v, false),
          ),
          if (_showDestinationList && _destinationPredictions.isNotEmpty)
            _buildPredictionList(_destinationPredictions, false),

          const SizedBox(height: 24),

          const Text(
            'Detalhes da Viagem',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: _selectTime,
                  decoration: const InputDecoration(
                    labelText: 'Horário',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _seatsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Assentos',
                    prefixIcon: Icon(Icons.event_seat),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) =>
                      cubit.updateBasicInfo(seats: int.tryParse(v)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor Total (R\$)',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) =>
                      cubit.updateBasicInfo(price: double.tryParse(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Embarque e Taxas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _pickupFeeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Taxa de Busca (R\$)',
              helperText: 'Valor extra para buscar em local específico',
              prefixIcon: Icon(Icons.add_circle_outline),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) =>
                cubit.updateBasicInfo(pickupFee: double.tryParse(v)),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _boardingController,
            decoration: InputDecoration(
              labelText: 'Local de Embarque Padrão',
              hintText: 'Ex: Rodoviária, Posto X...',
              prefixIcon: const Icon(Icons.map),
              suffixIcon: IconButton(
                icon: const Icon(Icons.pin_drop, color: Colors.blue),
                onPressed: () => _openMapPicker(context),
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => cubit.updateBasicInfo(originBoardingName: v),
          ),
        ],
      ),
    );
  }
}
