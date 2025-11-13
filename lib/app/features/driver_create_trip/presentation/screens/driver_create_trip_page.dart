import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/core/services/service_locator.dart';
// --- IMPORT DO DEBOUNCER ---
import 'package:plumo/app/core/utils/debouncer.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_cubit.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_state.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/models/waypoint_form_model.dart';
import 'package:intl/intl.dart';

// (O 'DriverCreateTripPage' (Stateless) continua o mesmo)
class DriverCreateTripPage extends StatelessWidget {
  const DriverCreateTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CreateTripCubit>(),
      child: const _DriverCreateTripView(),
    );
  }
}

class _DriverCreateTripView extends StatefulWidget {
  const _DriverCreateTripView();

  @override
  State<_DriverCreateTripView> createState() => _DriverCreateTripViewState();
}

// (Os imports e as classes 'DriverCreateTripPage' e
// '_DriverCreateTripView' (StatefulWidget) continuam iguais)

class _DriverCreateTripViewState extends State<_DriverCreateTripView> {
  final _formKey = GlobalKey<FormState>();
  final _places = sl<FlutterGooglePlacesSdk>();
  final _debouncer = Debouncer(milliseconds: 500);

  // Controladores principais
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  // Controladores de Waypoint
  final List<WaypointFormModel> _waypointForms = [];
  List<AutocompletePrediction> _predictions = [];
  int? _currentlyEditingIndex;

  // Estado para o stepper de assentos
  int _availableSeats = 3;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _addWaypoint(); // Origem
    _addWaypoint(); // Destino
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    for (var form in _waypointForms) {
      form.dispose();
    }
    super.dispose();
  }

  // --- LÓGICA DE UI (sem alterações) ---
  void _addWaypoint() {
    final newForm = WaypointFormModel();
    newForm.focusNode.addListener(() {
      if (newForm.focusNode.hasFocus) {
        setState(() {
          _currentlyEditingIndex = _waypointForms.indexOf(newForm);
        });
      } else {
        setState(() {
          _currentlyEditingIndex = null;
          _predictions = [];
        });
      }
    });
    newForm.placeController.addListener(() {
      if (newForm.focusNode.hasFocus) {
        _onSearchChanged(
          newForm.placeController.text,
          _waypointForms.indexOf(newForm),
        );
      }
    });
    setState(() {
      _waypointForms.add(newForm);
    });
  }

  void _removeWaypoint(int index) {
    setState(() {
      _waypointForms[index].dispose();
      _waypointForms.removeAt(index);
    });
  }

  void _onSearchChanged(String query, int index) {
    // (Lógica de invalidação e debounce - sem alterações)
    if (_waypointForms[index].place != null &&
        query != _waypointForms[index].place!.address) {
      setState(() {
        _waypointForms[index].place = null;
      });
    }
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }
    _debouncer.run(() async {
      try {
        final result = await _places.findAutocompletePredictions(
          query,
          countries: ['BR'],
        );
        setState(() {
          _predictions = result.predictions;
        });
      } catch (e) {
        print('Erro no findAutocompletePredictions: $e');
      }
    });
  }

  Future<void> _onPredictionSelected(AutocompletePrediction prediction) async {
    // (Lógica de seleção - sem alterações)
    if (_currentlyEditingIndex == null) return;
    try {
      final placeDetails = await _places.fetchPlace(
        prediction.placeId,
        fields: [
          PlaceField.Address,
          PlaceField.Location,
          PlaceField.Name,
          PlaceField.Id,
        ],
      );
      if (placeDetails.place == null || placeDetails.place!.address == null) {
        return;
      }
      final Place selectedPlace = placeDetails.place!;
      final int index = _currentlyEditingIndex!;
      setState(() {
        _waypointForms[index].place = selectedPlace;
        _waypointForms[index].placeController.text = selectedPlace.address!;
        _predictions = [];
        FocusScope.of(context).unfocus();
      });
    } catch (e) {
      print('Erro no fetchPlace: $e');
    }
  }

  Future<void> _selectDate() async {
    // (Lógica de _selectDate - sem alterações)
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (pickedDate == null) return;
    if (!mounted) return;
    setState(() {
      _selectedDate = pickedDate;
      _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  Future<void> _selectTime() async {
    // (Lógica de _selectTime - sem alterações)
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    if (pickedTime == null) return;
    if (!mounted) return;
    setState(() {
      _selectedTime = pickedTime;
      _timeController.text = pickedTime.format(context);
    });
  }

  void _incrementSeats() {
    if (_availableSeats < 10) {
      setState(() {
        _availableSeats++;
      });
    }
  }

  void _decrementSeats() {
    if (_availableSeats > 1) {
      setState(() {
        _availableSeats--;
      });
    }
  }

  // --- NOVA FUNÇÃO (Passo 17.24) ---
  /// Limpa todos os campos do formulário após o sucesso
  void _resetForm() {
    _dateController.clear();
    _timeController.clear();
    _selectedDate = null;
    _selectedTime = null;
    _predictions = [];
    _currentlyEditingIndex = null;

    // Limpa e descarta os controladores antigos
    for (var form in _waypointForms) {
      form.dispose();
    }
    _waypointForms.clear();

    // Reinicia o estado
    setState(() {
      _availableSeats = 3;
    });

    // Adiciona os dois campos iniciais (Origem/Destino)
    _addWaypoint();
    _addWaypoint();
  }

  void _onSubmit() {
    // (Lógica de validação - sem alterações)
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione Data e Horário da Partida.')),
      );
      return;
    }
    if (_waypointForms.length < 2 ||
        _waypointForms.any(
          (f) =>
              f.place == null ||
              (f != _waypointForms.first && f.priceController.text.isEmpty),
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Use a busca para preencher todos os locais e preços (mínimo 2).',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Perfil do motorista não encontrado.'),
        ),
      );
      return;
    }

    // (Lógica de combinação de Data/Hora - sem alterações)
    final DateTime departureTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // --- LÓGICA DE PREÇO (Passo 17.22) ---
    final List<TripWaypointEntity> waypoints = [];
    for (int i = 0; i < _waypointForms.length; i++) {
      final form = _waypointForms[i];
      final double price;
      if (i == 0) {
        // Regra de Negócio: A Origem (index 0) é sempre R$ 0.00
        price = 0.0;
      } else {
        // Para todos os outros (Destino/Paradas), lemos o campo
        final priceString = form.priceController.text.replaceAll(',', '.');
        price = double.parse(priceString); // <-- Agora só roda para i > 0
      }

      waypoints.add(
        TripWaypointEntity(
          order: i,
          placeName: form.place!.address!,
          placeGoogleId: form.place!.id!,
          latitude: form.place!.latLng!.lat,
          longitude: form.place!.latLng!.lng,
          price: price, // <-- Preço corrigido
        ),
      );
    }

    // (Chamada do Cubit - sem alterações)
    context.read<CreateTripCubit>().submitCreateTrip(
      driverProfile: authState.profile,
      departureTime: departureTime,
      availableSeats: _availableSeats,
      waypoints: waypoints,
    );
  }

  // --- MÉTODO BUILD (UI) TOTALMENTE REFATORADO ---
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateTripCubit, CreateTripState>(
      listener: (context, state) {
        if (state is CreateTripError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }

        // --- LÓGICA ATUALIZADA (Passo 17.24) ---
        if (state is CreateTripSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Viagem criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          // Chama a função de limpeza
          _resetForm();
        }
        // ------------------------------------
      },
      builder: (context, state) {
        final bool isLoading = state is CreateTripLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Criar Nova Viagem')),
          body: SizedBox.expand(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    // --- MUDANÇA DE UI (Passo 17.23) ---
                    // Adicionamos padding extra embaixo para o botão flutuante
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- UI: DETALHES DA VIAGEM ---
                          const Text(
                            'Detalhes da Viagem',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Campo Data
                              Expanded(
                                child: TextFormField(
                                  controller: _dateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Data da Viagem',
                                    prefixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: true,
                                  onTap: _selectDate,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Obrigatório'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Campo Hora
                              Expanded(
                                child: TextFormField(
                                  controller: _timeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Horário de Saída',
                                    prefixIcon: Icon(Icons.access_time),
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: true,
                                  onTap: _selectTime,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Obrigatório'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Stepper de Assentos
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Assentos Disponíveis',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: _decrementSeats,
                                      iconSize: 28,
                                    ),
                                    Text(
                                      '$_availableSeats',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: _incrementSeats,
                                      iconSize: 28,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 32),

                          // --- UI: ROTA E PREÇOS ---
                          const Text(
                            'Rota e Preços',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Lista Dinâmica de Waypoints
                          ListView.builder(
                            itemCount: _waypointForms.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final form = _waypointForms[index];
                              return _buildWaypointCard(form, index);
                            },
                          ),

                          // --- BOTÃO ATUALIZADO (Passo 17.23) ---
                          // (Estilo do seu 'image_ac339e.png')
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar Ponto de Parada'),
                              onPressed: _addWaypoint,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40), // Espaço extra
                        ],
                      ),
                    ),
                  ),

                  // Lista Flutuante de Autocomplete
                  if (_currentlyEditingIndex != null && _predictions.isNotEmpty)
                    _buildPredictionsFollower(),

                  // Camada de Loading
                  if (isLoading)
                    Container(
                      color: Colors.black.withAlpha(128),
                      child: const Center(child: CircularProgressIndicator()),
                    ),

                  // --- BOTÃO SALVAR (Estilo Flutuante) ---
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Theme.of(
                        context,
                      ).scaffoldBackgroundColor, // Fundo do scaffold
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Criar Viagem'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// --- WIDGET AUXILIAR ATUALIZADO (Passo 17.23) ---
  Widget _buildWaypointCard(WaypointFormModel form, int index) {
    bool isOrigin = index == 0;
    String title = isOrigin ? 'Local de Origem' : 'Local de Destino';
    // Define o título (Origem, Destino, ou Parada 3, Parada 4...)
    if (!isOrigin && index > 1) {
      title = 'Ponto de Parada ${index + 1}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // Botão de Remover (só aparece se houver mais de 2 paradas)
                if (_waypointForms.length > 2)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeWaypoint(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Campo de Local
            CompositedTransformTarget(
              link: form.layerLink,
              child: TextFormField(
                controller: form.placeController,
                focusNode: form.focusNode,
                decoration: const InputDecoration(
                  hintText: 'Digite o endereço',
                  prefixIcon: Icon(Icons.location_pin),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Obrigatório' : null,
              ),
            ),

            // --- CORREÇÃO (Passo 17.23): Oculta o preço se for Origem ---
            if (!isOrigin)
              Column(
                children: [
                  const SizedBox(height: 12),
                  // Campo de Preço
                  TextFormField(
                    controller: form.priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço da Passagem (até este ponto)',
                      prefixText: 'R\$ ',
                      hintText: '0,00',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (isOrigin) {
                        // Segurança, embora esteja oculto
                        form.priceController.text = '0,00';
                        return null;
                      }
                      if (v == null || v.isEmpty) return 'Obrigatório';
                      if (double.tryParse(v.replaceAll(',', '.')) == null) {
                        return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // (Widget _buildPredictionsList - sem alterações)
  Widget _buildPredictionsFollower() {
    if (_currentlyEditingIndex == null) return Container();

    final form = _waypointForms[_currentlyEditingIndex!];

    return CompositedTransformFollower(
      link: form.layerLink,
      showWhenUnlinked: false,
      offset: const Offset(0.0, 60.0),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _predictions.length,
            itemBuilder: (context, index) {
              final prediction = _predictions[index];
              return ListTile(
                title: Text(prediction.primaryText),
                subtitle: Text(prediction.secondaryText),
                onTap: () {
                  _onPredictionSelected(prediction);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
