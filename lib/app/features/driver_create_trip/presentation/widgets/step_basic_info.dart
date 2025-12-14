import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/core/utils/currency_input_formatter.dart';
import 'package:plumo/app/core/utils/debouncer.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_cubit.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_state.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/widgets/boarding_selector.dart';
import 'package:plumo/app/core/utils/address_formatter.dart';
import 'package:intl/intl.dart';

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
  final _pickupFeeController = TextEditingController(text: '0,00');

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
      _priceController.text = CurrencyInputFormatter.formatDouble(
        state.totalPrice,
      );
    }
    if (state.pickupFee > 0) {
      _pickupFeeController.text = CurrencyInputFormatter.formatDouble(
        state.pickupFee,
      );
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
          placeTypesFilter: [places.PlaceTypeFilter.CITIES],
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
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: predictions.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Colors.grey),
          itemBuilder: (context, index) {
            final item = predictions[index];

            // Limpeza visual do texto (Remove ", Brasil")
            String subtitle = item.secondaryText;
            subtitle = subtitle.replaceAll(RegExp(r', Bras?il$'), '');

            return ListTile(
              dense: true,
              leading: const Icon(Icons.location_city, color: Colors.blueGrey),
              title: Text(
                item.primaryText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              onTap: () => _onPredictionSelected(item, isOrigin),
            );
          },
        ),
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
            decoration: InputDecoration(
              labelText: 'Cidade de Origem',
              prefixIcon: const Icon(Icons.my_location),
              border: const OutlineInputBorder(),
              helperText:
                  'Digite apenas o nome da Cidade e selecione corretamente',
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _originController,
                builder: (context, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _originController.clear();
                      _onSearchChanged('', true);
                      context.read<CreateTripCubit>().clearOrigin();
                    },
                  );
                },
              ),
            ),
            onChanged: (v) => _onSearchChanged(v, true),
          ),
          if (_showOriginList && _originPredictions.isNotEmpty)
            _buildPredictionList(_originPredictions, true),

          const SizedBox(height: 16),

          TextFormField(
            controller: _destinationController,
            decoration: InputDecoration(
              labelText: 'Cidade de Destino',
              prefixIcon: const Icon(Icons.location_on),
              border: const OutlineInputBorder(),
              helperText:
                  'Digite apenas o nome da Cidade e selecione corretamente',
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _destinationController,
                builder: (context, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _destinationController.clear();
                      _onSearchChanged('', false);
                      context.read<CreateTripCubit>().clearDestination();
                    },
                  );
                },
              ),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Só aceita números
                    CurrencyInputFormatter(), // Formata como 0,00
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Valor Total (R\$)',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    hintText: '0,00',
                  ),
                  onChanged: (v) {
                    final doubleVal = CurrencyInputFormatter.parse(v);
                    context.read<CreateTripCubit>().updateBasicInfo(
                      price: doubleVal,
                    );
                  },
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: const InputDecoration(
              labelText: 'Taxa de Busca (R\$)',
              helperText: 'Valor extra para buscar em local específico',
              prefixIcon: Icon(Icons.add_circle_outline),
              border: OutlineInputBorder(),
              hintText: '0,00',
            ),
            onChanged: (v) {
              final doubleVal = CurrencyInputFormatter.parse(v);
              context.read<CreateTripCubit>().updateBasicInfo(
                pickupFee: doubleVal,
              );
            },
          ),
          const SizedBox(height: 16),

          BlocBuilder<CreateTripCubit, CreateTripState>(
            builder: (context, state) {
              return BoardingSelector(
                selectedName: state.originBoardingName,
                // Passa a coordenada da cidade de origem como referência para abrir o mapa
                referenceLocation: state.originCoords,

                onLocationSelected: (result) {
                  final name = result['name'] as String;
                  final coords = result['coords'] as LatLng;

                  // Atualiza o Cubit
                  context.read<CreateTripCubit>().updateBasicInfo(
                    originBoardingName: name,
                    originBoardingCoords: coords,
                  );
                },

                onClear: () {
                  // Limpa no Cubit
                  context.read<CreateTripCubit>().updateBasicInfo(
                    originBoardingName: null,
                    originBoardingCoords: null,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
