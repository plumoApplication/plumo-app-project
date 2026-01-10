import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Necessário para datas em PT-BR
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_state.dart';
import 'package:plumo/app/features/profile/domain/entities/profile_entity.dart';
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Para LatLng
import 'package:plumo/app/features/booking/presentation/widgets/booking_map_picker.dart'; // O novo widget

// Importe o seu picker de mapa aqui (se moveu para o core)
// import 'package:plumo/app/core/widgets/location_picker_modal.dart';

class BookingConfirmationPage extends StatefulWidget {
  final TripSearchResultEntity trip;

  const BookingConfirmationPage({super.key, required this.trip});

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  // Estados Locais
  int _selectedSeats = 1;
  String? _selectedPaymentMethod; // 'pix' ou 'credit_card'
  bool _wantDoorToDoor = false;
  String? _customPickupAddress;
  double? _customPickupLat;
  double? _customPickupLng;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Calcula preço total
  double get _totalPrice {
    double base = widget.trip.price * _selectedSeats;
    if (_wantDoorToDoor) {
      base += widget
          .trip
          .pickupFee; // Taxa é por viagem ou por assento? Geralmente por viagem (grupo). Assumindo taxa fixa.
    }
    return base;
  }

  //Alterando o "." para a "," nos valores
  final _currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<BookingCubit>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Confirmar Reserva"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: BlocConsumer<BookingCubit, BookingState>(
            listener: (context, state) {
              if (state is BookingSuccess) {
                // Navegar para uma tela de sucesso final ou voltar para home
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sua reserva foi enviada!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is BookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Resumo da Viagem (Header Clean)
                    _buildTripSummaryHeader(),
                    const SizedBox(height: 24),

                    // 2. Stepper Horizontal
                    _buildHorizontalStepper(),
                    const SizedBox(height: 24),

                    // 3. Seleção de Assentos
                    _buildSeatSelector(),
                    const SizedBox(height: 24),

                    // 4. Porta a Porta (Mapa)
                    if (widget.trip.pickupFee > 0) ...[
                      _buildDoorToDoorSection(),
                      const SizedBox(height: 24),
                    ],

                    // 5. Pagamento
                    _buildPaymentSelector(),
                    const SizedBox(height: 24),

                    // 6. Mensagem
                    const Text(
                      "Mensagem para o motorista (Opcional)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Ex: Estou levando uma mala grande...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
        bottomSheet: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildTripSummaryHeader() {
    final date = widget.trip.departureTime;
    // Formato: Segunda, 29 de Janeiro de 2026
    final dateStr = DateFormat(
      "EEEE, d 'de' MMMM 'de' y",
      "pt_BR",
    ).format(date);
    // Capitaliza a primeira letra do dia da semana
    final formattedDate = dateStr.replaceFirst(
      dateStr[0],
      dateStr[0].toUpperCase(),
    );
    final timeStr = DateFormat("HH:mm").format(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                "Saída às $timeStr",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStepper() {
    return Row(
      children: [
        // Origem
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "DE",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.trip.displayOrigin,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Seta e Ícones
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.blue),
              Container(width: 40, height: 1, color: Colors.grey[300]),
              const Icon(Icons.location_on, size: 16, color: Colors.red),
            ],
          ),
        ),
        // Destino
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "PARA",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.trip.displayDestination,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeatSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Assentos",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _selectedSeats > 1
                    ? () => setState(() => _selectedSeats--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                "$_selectedSeats",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _selectedSeats < widget.trip.availableSeats
                    ? () => setState(() => _selectedSeats++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoorToDoorSection() {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            "Me buscar em local específico?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("+ ${_currencyFormat.format(widget.trip.pickupFee)}"),
          value: _wantDoorToDoor,
          onChanged: (val) {
            setState(() {
              _wantDoorToDoor = val;
              if (!val) {
                _customPickupAddress = null;
                _customPickupLat = null;
                _customPickupLng = null;
              }
            });
          },
        ),
        if (_wantDoorToDoor)
          InkWell(
            onTap: _openMapPicker, // Implementar a abertura do mapa aqui
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withAlpha(77)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _customPickupAddress ?? "Toque para selecionar no mapa",
                      style: TextStyle(
                        color: _customPickupAddress == null
                            ? Colors.grey
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Forma de Pagamento",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _paymentOption(
                label: "PIX",
                icon: Icons
                    .pix, // Se não tiver ícone PIX, use um genérico ou asset
                value: 'pix',
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _paymentOption(
                label: "Cartão",
                icon: Icons.credit_card,
                value: 'credit_card',
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _paymentOption({
    required String label,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final isLoading = state is BookingLoading;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Final",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _currencyFormat.format(_totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _submitBooking(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Confirmar Solicitação",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMapPicker() async {
    // 1. Definição do Fallback (São Paulo) para último caso
    double targetLat = -23.5505;
    double targetLng = -46.6333;

    // O nome do local onde o passageiro vai embarcar (Ex: "Goaninha" ou "Natal")
    final String boardingName = widget.trip.displayOrigin;
    bool coordinateFound = false;

    // 2. Estratégia A: Tenta encontrar nas PARADAS (Waypoints)
    // Se o passageiro escolheu embarcar em uma cidade que é ponto de parada,
    // a coordenada correta está na lista de waypoints, não na origem da trip.
    for (var wp in widget.trip.waypoints) {
      // Comparação flexível de texto (ignora maiúsculas/minúsculas)
      if (wp.placeName.toLowerCase().contains(boardingName.toLowerCase()) ||
          boardingName.toLowerCase().contains(wp.placeName.toLowerCase())) {
        if (wp.latitude != 0.0 && wp.longitude != 0.0) {
          targetLat = wp.latitude;
          targetLng = wp.longitude;
          coordinateFound = true;
          break;
        }
      }
    }

    // 3. Estratégia B: Se não achou nos waypoints, usa a ORIGEM DA VIAGEM
    if (!coordinateFound) {
      if (widget.trip.originLat != null && widget.trip.originLat != 0.0) {
        targetLat = widget.trip.originLat!;
        targetLng = widget.trip.originLng!;
        coordinateFound = true;
      }
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingMapPicker(
          initialLocation: LatLng(targetLat, targetLng),
          initialName: _customPickupAddress,
          initialLat: targetLat,
          initialLng: targetLng,
        ),
      ),
    );

    if (result != null && result is Map) {
      final LatLng coords = result['coords'];
      final String name = result['name'];

      setState(() {
        _customPickupAddress = name;
        _customPickupLat = coords.latitude;
        _customPickupLng = coords.longitude;
      });
    }
  }

  void _submitBooking(BuildContext context) {
    FocusScope.of(context).unfocus();
    final authState = context.read<AuthCubit>().state;
    String? passengerId;
    if (authState is Authenticated) {
      passengerId = authState.profile.id;
    } else if (authState is ProfileIncomplete) {
      passengerId = authState.profile.id;
    }

    if (passengerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: Usuário não identificado")),
      );
      return;
    }
    //Obriga a seleção do pagamento
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecione uma forma de pagamento."),
          backgroundColor: Colors.orange, // Cor de alerta
        ),
      );
      return;
    }

    // Se escolheu porta a porta mas não definiu local, avisa
    if (_wantDoorToDoor && _customPickupAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione o local de busca no mapa")),
      );
      return;
    }

    String finalPickupAddress;
    double finalPickupLat;
    double finalPickupLng;

    if (_wantDoorToDoor) {
      // CASO 1: Porta a Porta (Customizado)
      // Aqui usamos o tratamento de nulo com fallback seguro (embora a validação anterior já garanta)
      finalPickupAddress = _customPickupAddress ?? "Endereço personalizado";
      finalPickupLat = _customPickupLat ?? 0.0;
      finalPickupLng = _customPickupLng ?? 0.0;
    } else {
      // CASO 2: Ponto de Encontro (Padrão)
      // 1. Variáveis iniciais assumindo a Origem Principal (Ponto A)
      String tempAddress =
          widget.trip.boardingPlaceName ?? widget.trip.originName ?? "Origem";
      double tempLat = widget.trip.boardingLat ?? widget.trip.originLat ?? 0.0;
      double tempLng = widget.trip.boardingLng ?? widget.trip.originLng ?? 0.0;
      // 2. Normalização para busca (caixa baixa)
      final searchOrigin = widget.trip.displayOrigin.toLowerCase().trim();
      // [CORREÇÃO 1] Removida a variável 'mainOrigin' que não estava sendo usada.
      // 3. Busca nos Waypoints
      if (widget.trip.waypoints.isNotEmpty) {
        for (var wp in widget.trip.waypoints) {
          // [CORREÇÃO 2] Removido '?? ""'. O linter avisou que placeName nunca é nulo.
          final wpName = wp.placeName.toLowerCase().trim();
          // Verifica se o nome do waypoint bate com o que está sendo exibido na tela
          if (wpName.isNotEmpty &&
              (searchOrigin.contains(wpName) ||
                  wpName.contains(searchOrigin))) {
            // Prioridade para coordenadas de embarque específicas do waypoint
            if (wp.boardingLat != null && wp.boardingLat != 0.0) {
              tempLat = wp.boardingLat!;
              tempLng = wp.boardingLng!;
              // [CORREÇÃO 3] Simplificação da atribuição.
              // Se boardingPlaceName for nulo, usa placeName (que sabemos que não é nulo).
              // Não precisamos do '?? tempAddress' no final pois placeName garante valor.
              tempAddress = wp.boardingPlaceName ?? wp.placeName;
            } else {
              tempLat = wp.latitude;
              tempLng = wp.longitude;
              // [CORREÇÃO 4] Mesma lógica: placeName não é nulo.
              tempAddress = wp.placeName;
            }
            // [CORREÇÃO 5] Removemos 'foundInWaypoints = true', pois o break já resolve.
            break;
          }
        }
      }

      finalPickupAddress = tempAddress;
      finalPickupLat = tempLat;
      finalPickupLng = tempLng;
    }

    // Criação do perfil temporário do motorista para a entidade (se necessário visualmente)
    final tempDriverProfile = ProfileEntity(
      id: widget.trip.driverId ?? '',
      fullName: widget.trip.driverName,
      role: 'driver',
      createdAt: DateTime.now(),
    );

    final bookingRequest = BookingEntity(
      tripId: widget.trip.id ?? '',
      passengerId: passengerId,
      driverId: widget.trip.driverId ?? '',
      originName: widget.trip.displayOrigin,
      destinationName: widget.trip.displayDestination,
      seats: _selectedSeats,
      totalPrice: _totalPrice,
      status: 'pending',
      createdAt: DateTime.now(),
      pickupAddress: finalPickupAddress,
      pickupLat: finalPickupLat,
      pickupLng: finalPickupLng,
      message: _messageController.text,
      paymentMethod: _selectedPaymentMethod,

      driverProfile: tempDriverProfile,
      isCustomPickup: _wantDoorToDoor,
    );
    // Dialog de Confirmação, antes de enviar a solicitação da reserva
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Confirmar Solicitação"),
          content: const Text(
            "Confirme os dados da sua solicitação. Caso ja esteja ciente das opções que selecionou para sua solicitação, aperte em confirmar.",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(), // Fecha o dialog
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o dialog
                // Chama o Cubit para efetivar a reserva
                context.read<BookingCubit>().createBooking(
                  booking: bookingRequest,
                );
              },
              child: const Text(
                "Confirmar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
