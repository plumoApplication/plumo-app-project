import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/core/utils/debouncer.dart';
import 'package:plumo/app/core/utils/address_formatter.dart';

class SearchCityField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final ValueChanged<places.Place?> onPlaceSelected;

  const SearchCityField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.onPlaceSelected,
  });

  @override
  State<SearchCityField> createState() => _SearchCityFieldState();
}

class _SearchCityFieldState extends State<SearchCityField> {
  final _places = sl<places.FlutterGooglePlacesSdk>();
  final _debouncer = Debouncer(milliseconds: 500);

  List<places.AutocompletePrediction> _predictions = [];
  bool _showList = false;
  bool _isLoading = false;

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _showList = false;
      });
      // Limpa a seleção anterior no pai se o usuário apagar o texto
      widget.onPlaceSelected(null);
      return;
    }

    _debouncer.run(() async {
      setState(() => _isLoading = true);
      try {
        final result = await _places.findAutocompletePredictions(
          query,
          countries: ['BR'],
          placeTypesFilter: [places.PlaceTypeFilter.CITIES], // Só cidades
        );

        if (!mounted) return;

        setState(() {
          _predictions = result.predictions;
          _showList = _predictions.isNotEmpty;
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Erro na busca: $e');
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _selectPrediction(places.AutocompletePrediction item) async {
    // Fecha a lista e coloca o texto no campo visualmente
    setState(() {
      _showList = false;
      _predictions = [];
      // Formata para ficar bonito (Ex: "João Pessoa - PB")
      // Remove o ", Brasil" que o Google manda
      widget.controller.text = item.primaryText;
    });
    FocusScope.of(context).unfocus(); // Fecha teclado

    // Busca detalhes (Lat/Lng) para passar pro pai
    try {
      final details = await _places.fetchPlace(
        item.placeId,
        fields: [
          places.PlaceField.Location,
          places.PlaceField.Name,
          places.PlaceField.Address,
          places.PlaceField.Id,
        ],
      );

      if (details.place != null) {
        widget.onPlaceSelected(details.place);
      }
    } catch (e) {
      debugPrint('Erro ao buscar detalhes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // O Campo de Texto
        TextFormField(
          controller: widget.controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon, color: Colors.grey),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      widget.controller.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        // A Lista de Sugestões (Dropdown)
        if (_showList)
          Container(
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
                itemCount: _predictions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _predictions[index];
                  // Limpeza visual do texto secundário (Estado)
                  final secondaryText = AddressFormatter.format(
                    item.secondaryText,
                  );

                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_city,
                      size: 20,
                      color: Colors.grey,
                    ),
                    title: Text(
                      item.primaryText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(secondaryText),
                    onTap: () => _selectPrediction(item),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
