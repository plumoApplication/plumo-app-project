import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/core/utils/debouncer.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_cubit.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_state.dart';
import 'package:plumo/app/features/trip_search/presentation/screens/trip_results_page.dart';
import 'package:plumo/app/features/announcements/presentation/cubit/announcements_cubit.dart';
import 'package:plumo/app/features/announcements/presentation/cubit/announcements_state.dart';
import 'package:plumo/app/features/announcements/presentation/widgets/announcements_carousel.dart';

/// Esta é a Aba 1 (Home) do Passageiro.
/// Agora ela gerencia seu próprio estado de busca.
class TripSearchPage extends StatelessWidget {
  final String userRole;
  const TripSearchPage({super.key, this.userRole = 'passenger'});

  @override
  Widget build(BuildContext context) {
    return _TripSearchView(userRole: userRole);
  }
}

// Convertemos o antigo StatefulWidget em um StatelessWidget interno
class _TripSearchView extends StatefulWidget {
  final String userRole;
  const _TripSearchView({required this.userRole});

  @override
  State<_TripSearchView> createState() => _TripSearchViewState();
}

class _TripSearchViewState extends State<_TripSearchView> {
  // (Controladores, FormKey, Places, Debouncer... tudo igual)
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _places = sl<FlutterGooglePlacesSdk>();
  List<AutocompletePrediction> _originPredictions = [];
  List<AutocompletePrediction> _destinationPredictions = [];
  bool _isSearchingOrigin = false;
  bool _isSearchingDestination = false;
  final _debouncer = Debouncer(milliseconds: 500);
  final FocusNode _originFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();
  Place? _originPlace;
  Place? _destinationPlace;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementsCubit>().loadAnnouncements(widget.userRole);
    });
    // (Listeners... tudo igual)
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
    // (Dispose... tudo igual)
    _originController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _originFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  // (onSearchChanged... tudo igual)
  void _onSearchChanged(String query, bool isOrigin) {
    // --- LÓGICA DE INVALIDAÇÃO (CORRIGIDA) ---
    // Verificamos se o usuário está "sujando" a seleção
    if (isOrigin && _originFocus.hasFocus) {
      // O usuário está digitando no campo Origem.
      // Se o texto digitado for DIFERENTE do endereço
      // do local que já salvamos, ENTÃO invalide o local.
      if (_originPlace != null && query != _originPlace!.address) {
        setState(() {
          _originPlace = null;
        });
      }
    } else if (!isOrigin && _destinationFocus.hasFocus) {
      // O usuário está digitando no campo Destino.
      if (_destinationPlace != null && query != _destinationPlace!.address) {
        setState(() {
          _destinationPlace = null;
        });
      }
    }
    // --- FIM DA LÓGICA DE INVALIDAÇÃO ---

    // A lógica de busca (com debounce) continua
    if (query.isEmpty) {
      setState(() {
        isOrigin ? _originPredictions = [] : _destinationPredictions = [];
      });
      return;
    }

    _debouncer.run(() async {
      try {
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

  Future<void> _onPredictionSelected(
    AutocompletePrediction prediction,
    bool isOrigin,
  ) async {
    try {
      final placeDetails = await _places.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.Address, PlaceField.Location, PlaceField.Name],
      );

      if (placeDetails.place == null || placeDetails.place!.address == null) {
        return;
      }

      final Place selectedPlace = placeDetails.place!;

      setState(() {
        if (isOrigin) {
          _originPlace = selectedPlace;
          _originController.text = selectedPlace.address!; // <-- USA O ENDEREÇO
          _originPredictions = [];
          FocusScope.of(context).requestFocus(_destinationFocus);
        } else {
          _destinationPlace = selectedPlace;
          _destinationController.text =
              selectedPlace.address!; // <-- USA O ENDEREÇO
          _destinationPredictions = [];
          FocusScope.of(context).unfocus();
        }
      });
    } catch (e) {
      print('Erro no fetchPlace: $e');
    }
  }

  // (selectDate... tudo igual)
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

  // --- LÓGICA DO BOTÃO "BUSCAR" ATUALIZADA ---
  void _onSearchPressed(BuildContext context) {
    // 1. Valida o formulário
    if (_formKey.currentState!.validate() &&
        _originPlace != null &&
        _destinationPlace != null) {
      // 2. Chama o Cubit (fornecido pelo BlocProvider acima)
      context.read<TripSearchCubit>().searchTrips(
        origin: _originPlace,
        destination: _destinationPlace,
        dateString: _dateController.text,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione os locais e a data.'),
        ),
      );
    }
  }

  void _clearForm() {
    _originController.clear();
    _destinationController.clear();
    _dateController.clear();

    setState(() {
      _originPlace = null;
      _destinationPlace = null;
      _originPredictions = [];
      _destinationPredictions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- O SCAFFOLD AGORA É "EMBRULHADO" POR UM BLOC CONSUMER ---
    return BlocConsumer<TripSearchCubit, TripSearchState>(
      listener: (context, state) {
        // --- LÓGICA DO LISTENER ---
        // Se o estado voltar para o 'Initial' (ex: após uma reserva)
        if (state is TripSearchInitial) {
          _clearForm();
        }
        // 3. Se a busca deu Erro (no futuro)
        if (state is TripSearchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }

        // 4. Se a busca deu Sucesso
        if (state is TripSearchSuccess) {
          // Navega para a tela de Resultados
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TripResultsPage(results: state.results),
            ),
          );
        }
      },
      builder: (context, state) {
        // 5. Verifica se estamos carregando (para desabilitar o botão)
        final bool isLoading = state is TripSearchLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Buscar Viagem')),
          body: SizedBox.expand(
            child: GestureDetector(
              onTap: () {
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
                          BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
                            builder: (context, state) {
                              if (state is AnnouncementsLoaded &&
                                  state.announcements.isNotEmpty) {
                                return Column(
                                  children: [
                                    AnnouncementsCarousel(
                                      announcements: state.announcements,
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                );
                              }
                              // Se estiver carregando ou vazio, não mostra nada (ou um loader pequeno)
                              return const SizedBox.shrink();
                            },
                          ),
                          TextFormField(
                            controller: _originController,
                            focusNode: _originFocus,
                            decoration: const InputDecoration(
                              labelText: 'De (Origem)',
                              hintText: 'Digite o local de partida',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Campo obrigatório'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _destinationController,
                            focusNode: _destinationFocus,
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

                          // --- BOTÃO "BUSCAR" ATUALIZADO ---
                          ElevatedButton(
                            // Chama o _onSearchPressed com o 'context'
                            // e é desabilitado se 'isLoading' for true
                            onPressed: isLoading
                                ? null
                                : () => _onSearchPressed(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Buscar Viagens'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // (Lista de Autocomplete "Origem"... tudo igual)
                  if (_isSearchingOrigin && _originPredictions.isNotEmpty)
                    _buildPredictionsList(_originPredictions, true),

                  // (Lista de Autocomplete "Destino"... tudo igual)
                  if (_isSearchingDestination &&
                      _destinationPredictions.isNotEmpty)
                    _buildPredictionsList(_destinationPredictions, false),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // (Widget auxiliar _buildPredictionsList... tudo igual)
  Widget _buildPredictionsList(
    List<AutocompletePrediction> predictions,
    bool isOrigin,
  ) {
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
            padding: EdgeInsets.zero,
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
