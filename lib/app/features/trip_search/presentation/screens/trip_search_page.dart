// lib/app/features/trip_search/presentation/screens/trip_search_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/core/utils/debouncer.dart'; // Nosso Debouncer

class TripSearchPage extends StatefulWidget {
  const TripSearchPage({super.key});

  @override
  State<TripSearchPage> createState() => _TripSearchPageState();
}

class _TripSearchPageState extends State<TripSearchPage> {
  // Controladores
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // A instância do SDK vinda do GetIt
  final _places = sl<FlutterGooglePlacesSdk>();

  // Gerenciamento de Estado da UI de Busca
  List<AutocompletePrediction> _originPredictions = [];
  List<AutocompletePrediction> _destinationPredictions = [];
  bool _isSearchingOrigin = false;
  bool _isSearchingDestination = false;

  // Debouncer (para economizar custos de API)
  final _debouncer = Debouncer(milliseconds: 500);

  // Foco (para sabermos qual lista mostrar)
  final FocusNode _originFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();

  // Locais selecionados
  Place? _originPlace;
  Place? _destinationPlace;

  @override
  void initState() {
    super.initState();
    // Adiciona os 'listeners' para o autocomplete
    _originFocus.addListener(() {
      if (_originFocus.hasFocus) {
        setState(() {
          _isSearchingOrigin = true;
        });
      } else {
        setState(() {
          _isSearchingOrigin = false;
        });
      }
    });
    _destinationFocus.addListener(() {
      if (_destinationFocus.hasFocus) {
        setState(() {
          _isSearchingDestination = true;
        });
      } else {
        setState(() {
          _isSearchingDestination = false;
        });
      }
    });

    _originController.addListener(() {
      if (_originFocus.hasFocus) {
        _onSearchChanged(_originController.text, true);
      }
    });
    _destinationController.addListener(() {
      if (_destinationFocus.hasFocus) {
        _onSearchChanged(_destinationController.text, false);
      }
    });
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _originFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  // --- LÓGICA DE AUTOCOMPLETE ---

  // Chamado a cada tecla digitada (com debounce)
  void _onSearchChanged(String query, bool isOrigin) {
    if (query.isEmpty) {
      setState(() {
        isOrigin ? _originPredictions = [] : _destinationPredictions = [];
      });
      return;
    }

    // Usa o Debouncer
    _debouncer.run(() async {
      try {
        // 1. O MÉTODO CORRETO: findAutocompletePredictions
        final result = await _places.findAutocompletePredictions(
          query,
          countries: ['BR'],
        );

        // A CLASSE CORRETA: AutocompletePrediction
        setState(() {
          if (isOrigin) {
            _originPredictions = result.predictions;
          } else {
            _destinationPredictions = result.predictions;
          }
        });
      } catch (e) {
        print('Erro no findAutocompletePredictions: $e');
      }
    });
  }

  // Chamado quando o usuário clica em um item da lista
  Future<void> _onPredictionSelected(
    AutocompletePrediction prediction,
    bool isOrigin,
  ) async {
    try {
      // 2. O MÉTODO CORRETO: fetchPlace
      final placeDetails = await _places.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.Address, PlaceField.Location, PlaceField.Name],
      );

      if (placeDetails.place == null) return;

      setState(() {
        if (isOrigin) {
          _originPlace = placeDetails.place;
          _originController.text = prediction.fullText;
          _originPredictions = []; // Esconde a lista
          FocusScope.of(
            context,
          ).requestFocus(_destinationFocus); // Pula para o próximo
        } else {
          _destinationPlace = placeDetails.place;
          _destinationController.text = prediction.fullText;
          _destinationPredictions = []; // Esconde a lista
          FocusScope.of(context).unfocus(); // Esconde o teclado
        }
      });
    } catch (e) {
      print('Erro no fetchPlace: $e');
    }
  }

  // --- LÓGICA DO FORMULÁRIO ---

  void _onSearchPressed() {
    if (_formKey.currentState!.validate() &&
        _originPlace != null &&
        _destinationPlace != null) {
      print('Buscando viagem...');
      print(
        'Origem: ${_originPlace!.address} (Lat: ${_originPlace!.latLng?.lat})',
      );
      print(
        'Destino: ${_destinationPlace!.address} (Lat: ${_destinationPlace!.latLng?.lat})',
      );
      print('Data: ${_dateController.text}');
      // TODO: Chamar o Cubit de Busca
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione os locais e a data.'),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Viagem')),
      // Usamos um 'Stack' para colocar a lista de resultados
      // "flutuando" por cima do formulário
      body: SizedBox.expand(
        child: GestureDetector(
          onTap: () {
            // ...remove o foco de qualquer campo de texto.
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // O Formulário (embaixo)
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _originController,
                        focusNode: _originFocus, // Conecta o Foco
                        decoration: const InputDecoration(
                          labelText: 'De (Origem)',
                          hintText: 'Digite o local de partida',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                        // Não é mais 'readOnly', o usuário digita
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _destinationController,
                        focusNode: _destinationFocus, // Conecta o Foco
                        decoration: const InputDecoration(
                          labelText: 'Para (Destino)',
                          hintText: 'Digite o local de destino',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Data da Viagem',
                          hintText: 'Selecione a data',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () {
                          _selectDate(context);
                        },
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _onSearchPressed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Buscar Viagens'),
                      ),
                    ],
                  ),
                ),
              ),

              // --- A UI DE AUTOCOMPLETE (FLUTUANDO POR CIMA) ---

              // Lista de "Origem"
              if (_isSearchingOrigin && _originPredictions.isNotEmpty)
                _buildPredictionsList(_originPredictions, true),

              // Lista de "Destino"
              if (_isSearchingDestination && _destinationPredictions.isNotEmpty)
                _buildPredictionsList(_destinationPredictions, false),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para construir a lista de sugestões
  Widget _buildPredictionsList(
    List<AutocompletePrediction> predictions,
    bool isOrigin,
  ) {
    // Posiciona a lista abaixo do campo de texto correto
    final double topPosition = isOrigin ? 100.0 : 185.0;

    return Positioned(
      top: topPosition,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero, // Para a lista não ter tamanho infinito
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              final prediction = predictions[index];
              return ListTile(
                title: Text(prediction.primaryText),
                subtitle: Text(prediction.secondaryText),
                onTap: () {
                  _onPredictionSelected(prediction, isOrigin);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
