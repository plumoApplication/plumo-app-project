import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/announcements/presentation/cubit/announcements_cubit.dart';
import 'package:plumo/app/features/announcements/presentation/cubit/announcements_state.dart';
import 'package:plumo/app/features/announcements/presentation/widgets/announcements_carousel.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/recent_searches/recent_searches_cubit.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_cubit.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_state.dart';
import 'package:plumo/app/features/trip_search/presentation/widgets/search_city_field.dart';
import 'package:plumo/app/features/trip_search/presentation/screens/trip_results_page.dart';
import 'package:plumo/app/core/database/app_database.dart';
import 'package:plumo/app/features/trip_search/presentation/widgets/recent_searches_list.dart';

class TripSearchPage extends StatelessWidget {
  const TripSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<TripSearchCubit>()),
        BlocProvider(
          create: (context) => sl<RecentSearchesCubit>()..loadRecentSearches(),
        ),
        BlocProvider(
          create: (context) =>
              sl<AnnouncementsCubit>()..loadAnnouncements('passenger'),
        ),
      ],
      child: const _TripSearchView(),
    );
  }
}

class _TripSearchView extends StatefulWidget {
  const _TripSearchView();

  @override
  State<_TripSearchView> createState() => _TripSearchViewState();
}

class _TripSearchViewState extends State<_TripSearchView> {
  // Controladores de Texto
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();

  // Variáveis de Estado para guardar os objetos reais
  Place? _originPlace;
  Place? _destinationPlace;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE DATA ---
  // Abre o calendário nativo
  Future<void> _selectDate() async {
    final now = DateTime.now();
    // Use a cor primária do tema atual de forma segura
    final primaryColor = Theme.of(context).primaryColor;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor, // Cor do cabeçalho e seleção
              onPrimary: Colors.white, // Cor do texto no cabeçalho
              onSurface: Colors.black, // Cor dos dias não selecionados
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    primaryColor, // Cor dos botões "Cancelar" e "OK"
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // --- AÇÃO AO CLICAR NA BUSCA RECENTE ---
  void _onRecentSearchSelected(RecentSearch search) {
    // 1. Preenche os textos
    _originController.text = search.originText;
    _destinationController.text = search.destinationText;

    // 2. Reconstrói os objetos Place (Manual, pois o Drift salvou os dados brutos)
    // O flutter_google_places_sdk permite criar um Place manualmente
    setState(() {
      _originPlace = _createMinimalPlace(
        id: search.originPlaceId,
        name: search.originText,
        lat: search.originLat,
        lng: search.originLng,
      );

      _destinationPlace = _createMinimalPlace(
        id: search.destinationPlaceId,
        name: search.destinationText,
        lat: search.destinationLat,
        lng: search.destinationLng,
      );

      // 3. Lógica inteligente de data
      // Se a data salva já passou, define para HOJE. Se é futura, mantém.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (search.tripDate.isBefore(today)) {
        _selectedDate = today; // Data antiga -> Vai para hoje
      } else {
        _selectedDate = search.tripDate; // Data futura -> Mantém
      }

      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    });
  }

  Place _createMinimalPlace({
    required String id,
    required String name,
    required double lat,
    required double lng,
  }) {
    return Place(
      id: id,
      name: name,
      latLng: LatLng(lat: lat, lng: lng),
      // --- Campos obrigatórios que não temos (passamos null) ---
      address: null,
      addressComponents: null,
      businessStatus: null,
      attributions: null,
      nameLanguageCode: null,
      openingHours: null,
      phoneNumber: null,
      photoMetadatas: null,
      plusCode: null,
      priceLevel: null,
      rating: null,
      types: null,
      userRatingsTotal: null,
      utcOffsetMinutes: null,
      viewport: null,
      websiteUri: null,
      reviews: null,
    );
  }

  // Ação do Botão Buscar
  void _onSearch() {
    // Validação Simples
    if (_originPlace == null ||
        _destinationPlace == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha origem, destino e data.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Salvar no histórico antes de buscar
    context.read<RecentSearchesCubit>().addSearch(
      originText:
          _originPlace!.name ?? _originController.text, // Garante ter texto
      originId: _originPlace!.id ?? '',
      originLat: _originPlace!.latLng?.lat ?? 0.0,
      originLng: _originPlace!.latLng?.lng ?? 0.0,
      destText: _destinationPlace!.name ?? _destinationController.text,
      destId: _destinationPlace!.id ?? '',
      destLat: _destinationPlace!.latLng?.lat ?? 0.0,
      destLng: _destinationPlace!.latLng?.lng ?? 0.0,
      date: _selectedDate!,
      reloadList: false,
    );

    // Dispara o Cubit de Busca de Viagem
    context.read<TripSearchCubit>().searchTrips(
      origin: _originPlace!,
      destination: _destinationPlace!,
      date: _selectedDate!,
    );
  }

  void _clearFields() {
    setState(() {
      _originController.clear();
      _destinationController.clear();
      _dateController.clear();

      _originPlace = null;
      _destinationPlace = null;
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Viagens'),
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocListener<TripSearchCubit, TripSearchState>(
        listener: (context, state) {
          if (state is TripSearchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TripSearchEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nenhuma viagem encontrada nesta data.'),
              ),
            );
          } else if (state is TripSearchSuccess) {
            // SUCESSO! Navega para a tela de resultados enviando a lista
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripResultsPage(
                  originCity: _originController.text,
                  destinationCity: _destinationController.text,
                  searchDate: _selectedDate ?? DateTime.now(),
                  trips: state.trips,
                ),
              ),
            ).then((_) {
              if (context.mounted) {
                context.read<RecentSearchesCubit>().loadRecentSearches();
                _clearFields();
              }
            });
            // Reseta o estado para quando o usuário voltar não navegar de novo
            context.read<TripSearchCubit>().resetSearch();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
                builder: (context, state) {
                  if (state is AnnouncementsLoaded &&
                      state.announcements.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: AnnouncementsCarousel(
                        announcements: state.announcements,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Text(
                'Para onde vamos?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Viaje com conforto, segurança e praticidade',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // 1. ORIGEM
              SearchCityField(
                label: 'Saindo de...',
                icon: Icons.my_location,
                controller: _originController,
                onPlaceSelected: (place) {
                  setState(() => _originPlace = place);
                },
              ),
              const SizedBox(height: 12),

              // 2. DESTINO
              SearchCityField(
                label: 'Indo para...',
                icon: Icons.location_on,
                controller: _destinationController,
                onPlaceSelected: (place) {
                  setState(() => _destinationPlace = place);
                },
              ),
              const SizedBox(height: 12),

              // 3. DATA (Campo ReadOnly com DatePicker)
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Data da Viagem',
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. BOTÃO BUSCAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: BlocBuilder<TripSearchCubit, TripSearchState>(
                  builder: (context, state) {
                    final isLoading = state is TripSearchLoading;

                    return ElevatedButton(
                      onPressed: isLoading ? null : _onSearch,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'BUSCAR VIAGENS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              RecentSearchesList(onSearchSelected: _onRecentSearchSelected),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
