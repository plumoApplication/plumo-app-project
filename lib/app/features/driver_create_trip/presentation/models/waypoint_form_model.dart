import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

/// Modelo de UI (Helper) para gerenciar o estado
/// de CADA linha do formulário de waypoint.
class WaypointFormModel {
  final TextEditingController placeController;
  final TextEditingController priceController;
  final FocusNode focusNode;
  Place? place; // O local selecionado no Google Places
  final LayerLink layerLink;

  WaypointFormModel()
    : placeController = TextEditingController(),
      priceController = TextEditingController(),
      focusNode = FocusNode(),
      layerLink = LayerLink(),
      place = null;

  // Precisamos de um método 'dispose' para limpar os controllers
  void dispose() {
    placeController.dispose();
    priceController.dispose();
    focusNode.dispose();
  }
}
