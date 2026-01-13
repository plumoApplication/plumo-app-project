import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/utils/currency_input_formatter.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_waypoint_entity.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/cubit/driver_trip_details_cubit.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/widgets/trip_edit_boarding_selector.dart';
import 'package:plumo/app/features/driver_trip_details/presentation/widgets/trip_edit_confirmation_dialog.dart';

class DriverEditTripPage extends StatefulWidget {
  final TripEntity trip;
  final List<BookingEntity> currentPassengers;

  const DriverEditTripPage({
    super.key,
    required this.trip,
    required this.currentPassengers,
  });

  @override
  State<DriverEditTripPage> createState() => _DriverEditTripPageState();
}

class _DriverEditTripPageState extends State<DriverEditTripPage> {
  // Controllers Principais
  late TextEditingController _mainPriceController;
  late TextEditingController _pickupFeeController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  // Estado Local de Edição
  String? _mainBoardingName;
  LatLng? _mainBoardingCoords;

  // Lista mutável de waypoints para edição
  late List<TripWaypointEntity> _editedWaypoints;
  // Controllers para os preços dos waypoints (mapa por índice)
  final Map<int, TextEditingController> _waypointPriceControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final trip = widget.trip;

    // 1. Valores Financeiros
    _mainPriceController = TextEditingController(
      text: NumberFormat.currency(
        locale: 'pt_BR',
        symbol: '',
      ).format(trip.price).trim(),
    );
    _pickupFeeController = TextEditingController(
      text: NumberFormat.currency(
        locale: 'pt_BR',
        symbol: '',
      ).format(trip.pickupFee).trim(),
    );

    // 2. Data e Hora
    _selectedDate = trip.departureTime;
    _selectedTime = TimeOfDay.fromDateTime(trip.departureTime);

    // 3. Embarque Principal (Origem)
    // [CORREÇÃO] Prioriza o boardingPlaceName se existir
    _mainBoardingName =
        (trip.boardingPlaceName != null && trip.boardingPlaceName!.isNotEmpty)
        ? trip.boardingPlaceName
        : trip.originName;

    // [CORREÇÃO] Prioriza a coordenada de embarque se existir
    if (trip.boardingLat != null && trip.boardingLng != null) {
      _mainBoardingCoords = LatLng(trip.boardingLat!, trip.boardingLng!);
    } else if (trip.originLat != null && trip.originLng != null) {
      _mainBoardingCoords = LatLng(trip.originLat!, trip.originLng!);
    } else {
      _mainBoardingCoords = const LatLng(-14.2350, -51.9253);
    }

    // 4. Waypoints (Cópia para edição)
    _editedWaypoints = List.from(trip.waypoints);
    for (int i = 0; i < _editedWaypoints.length; i++) {
      _waypointPriceControllers[i] = TextEditingController(
        text: NumberFormat.currency(
          locale: 'pt_BR',
          symbol: '',
        ).format(_editedWaypoints[i].price).trim(),
      );
    }
  }

  @override
  void dispose() {
    _mainPriceController.dispose();
    _pickupFeeController.dispose();
    for (var c in _waypointPriceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // --- LÓGICA DE SALVAMENTO ---

  void _onSavePressed() {
    double parseVal(String t) =>
        double.tryParse(t.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;

    final newMainPrice = parseVal(_mainPriceController.text);
    final newPickupFee = parseVal(_pickupFeeController.text);

    List<Map<String, dynamic>> waypointsSummary = [];
    List<TripWaypointEntity> finalWaypoints = [];

    for (int i = 0; i < _editedWaypoints.length; i++) {
      final wp = _editedWaypoints[i];
      final price = parseVal(_waypointPriceControllers[i]?.text ?? '0');

      final updatedWp = TripWaypointEntity(
        id: wp.id,
        tripId: wp.tripId,
        order: wp.order,
        placeName: wp.placeName,
        placeGoogleId: wp.placeGoogleId,
        latitude: wp.latitude,
        longitude: wp.longitude,
        price: price,
        createdAt: wp.createdAt,
        // Mantém os dados de embarque editados ou originais
        boardingPlaceName: wp.boardingPlaceName,
        boardingLat: wp.boardingLat,
        boardingLng: wp.boardingLng,
      );

      finalWaypoints.add(updatedWp);
      waypointsSummary.add({
        // Mostra o nome do local específico no resumo, se houver
        'name': wp.boardingPlaceName ?? wp.placeName,
        'price': price,
      });
    }

    showDialog(
      context: context,
      builder: (ctx) => TripEditConfirmationDialog(
        totalPrice: newMainPrice,
        pickupFee: newPickupFee,
        destinationName: widget.trip.destinationName ?? 'Destino',
        waypointsSummary: waypointsSummary,
        onConfirm: () {
          final newDateTime = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          );

          final updatedTrip = widget.trip.copyWith(
            price: newMainPrice,
            pickupFee: newPickupFee,
            departureTime: newDateTime,
            boardingPlaceName: _mainBoardingName,
            boardingLat: _mainBoardingCoords?.latitude,
            boardingLng: _mainBoardingCoords?.longitude,
            waypoints: finalWaypoints,
          );

          context.read<DriverTripDetailsCubit>().updateTripData(updatedTrip);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Viagem atualizada com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  // --- UI HELPERS ---

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DriverTripDetailsCubit>();
    final canEditDate = cubit.canEditDateTime(widget.currentPassengers);
    final canEditPrice = cubit.canEditPrice(widget.currentPassengers);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Editar Viagem"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DATA E HORA
            _buildSectionHeader("Data e Horário"),
            _buildDateTimeCard(canEditDate),

            const SizedBox(height: 24),

            // 2. VIAGEM PRINCIPAL
            _buildSectionHeader("Viagem Principal"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _mainPriceController,
                    keyboardType: TextInputType.number,
                    enabled: canEditPrice,
                    inputFormatters: [CurrencyInputFormatter()],
                    decoration: _buildInputDecoration(
                      "Valor Total (R\$)",
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _pickupFeeController,
                    keyboardType: TextInputType.number,
                    enabled: canEditPrice,
                    inputFormatters: [CurrencyInputFormatter()],
                    decoration: _buildInputDecoration(
                      "Taxa de Busca Extra (R\$)",
                      Icons.local_taxi,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SELETOR DA ORIGEM
                  TripEditBoardingSelector(
                    label: "Local de Embarque (Origem)",
                    selectedName: _mainBoardingName,
                    referenceLocation: _mainBoardingCoords,
                    onLocationSelected: (data) {
                      setState(() {
                        _mainBoardingName = data['name'];
                        _mainBoardingCoords = data['coords'];
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. PONTOS DE PARADA
            if (_editedWaypoints.isNotEmpty) ...[
              _buildSectionHeader("Pontos de Parada"),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _editedWaypoints.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildWaypointEditorItem(index, canEditPrice);
                },
              ),
              const SizedBox(height: 24),
            ],

            // 4. BOTÃO SALVAR
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onSavePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "SALVAR ALTERAÇÕES",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDateTimeCard(bool canEdit) {
    // (Código igual ao anterior)
    return InkWell(
      onTap: canEdit ? _pickDateTime : () => _showLockMsg(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today,
                color: Colors.blue[700],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data da Viagem",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat("dd/MM/yyyy 'às' HH:mm").format(
                      DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      ),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (canEdit)
              const Icon(Icons.edit, color: Colors.grey, size: 20)
            else
              const Icon(Icons.lock, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWaypointEditorItem(int index, bool canEdit) {
    final wp = _editedWaypoints[index];
    final controller = _waypointPriceControllers[index];

    // [CORREÇÃO 1]: Definir a coordenada correta do pin.
    // Se tiver boardingLat/Lng (editado ou do banco), usa. Se não, usa a lat/lng da cidade.
    final LatLng pinLocation =
        (wp.boardingLat != null && wp.boardingLng != null)
        ? LatLng(wp.boardingLat!, wp.boardingLng!)
        : LatLng(wp.latitude, wp.longitude);

    // [CORREÇÃO 2]: Definir o texto correto.
    // Se tiver boardingPlaceName (ex: Rodoviária), usa. Se não, usa o nome da cidade.
    final String displayName = wp.boardingPlaceName ?? wp.placeName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              // Mostra o nome do local de embarque no título também, fica mais coerente
              Expanded(
                child: Text(
                  "Parada ${index + 1}: $displayName",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TripEditBoardingSelector(
                  label: "Local na Parada",
                  // [CORREÇÃO 2 - Aplicação]: Passando o nome específico
                  selectedName: displayName,
                  // [CORREÇÃO 1 - Aplicação]: Passando a coordenada específica
                  referenceLocation: pinLocation,

                  onLocationSelected: (data) {
                    setState(() {
                      final newWp = TripWaypointEntity(
                        id: wp.id,
                        tripId: wp.tripId,
                        order: wp.order,
                        placeName: wp.placeName,
                        placeGoogleId: wp.placeGoogleId,
                        latitude: wp.latitude,
                        longitude: wp.longitude,
                        price: wp.price,
                        createdAt: wp.createdAt,

                        // Atualiza com os novos dados do seletor
                        boardingPlaceName: data['name'],
                        boardingLat: (data['coords'] as LatLng).latitude,
                        boardingLng: (data['coords'] as LatLng).longitude,
                      );
                      _editedWaypoints[index] = newWp;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  enabled: canEdit,
                  inputFormatters: [CurrencyInputFormatter()],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: "Valor (R\$)",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  void _showLockMsg() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Campo bloqueado pois existem reservas confirmadas."),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
