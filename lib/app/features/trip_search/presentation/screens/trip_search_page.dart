import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_cubit.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_state.dart';
import 'package:plumo/app/features/trip_search/presentation/widgets/search_city_field.dart';
import 'package:plumo/app/features/trip_search/presentation/screens/trip_results_page.dart';

class TripSearchPage extends StatelessWidget {
  const TripSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TripSearchCubit>(),
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

    // Dispara o Cubit
    context.read<TripSearchCubit>().searchTrips(
      origin: _originPlace!,
      destination: _destinationPlace!,
      date: _selectedDate!,
    );
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
                // Vamos construir essa tela no próximo passo!
                // Se der erro aqui agora, é normal.
                builder: (_) => TripResultsPage(trips: state.trips),
              ),
            );
            // Reseta o estado para quando o usuário voltar não navegar de novo
            context.read<TripSearchCubit>().resetSearch();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para onde vamos?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Encontre a carona perfeita para você.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // 1. ORIGEM (Novo Widget)
              SearchCityField(
                label: 'Saindo de...',
                icon: Icons.my_location,
                controller: _originController,
                onPlaceSelected: (place) {
                  setState(() => _originPlace = place);
                },
              ),
              const SizedBox(height: 16),

              // 2. DESTINO (Novo Widget)
              SearchCityField(
                label: 'Indo para...',
                icon: Icons.location_on,
                controller: _destinationController,
                onPlaceSelected: (place) {
                  setState(() => _destinationPlace = place);
                },
              ),
              const SizedBox(height: 16),

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

              const SizedBox(height: 32),

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
            ],
          ),
        ),
      ),
    );
  }
}
