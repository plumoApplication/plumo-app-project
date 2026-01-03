import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:plumo/app/features/booking/presentation/cubit/booking_state.dart';
import 'package:plumo/app/features/booking/presentation/widgets/boarding_location_sheet.dart';

class BookingDetailPage extends StatefulWidget {
  final BookingEntity booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final _currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
  late String? _currentStatus;
  late BookingCubit _bookingCubit;

  @override
  void initState() {
    super.initState();
    _bookingCubit = sl<BookingCubit>();
    _currentStatus = widget.booking.status;
  }

  @override
  void dispose() {
    _bookingCubit.close();
    super.dispose();
  }

  void _showPickupLocationModal(BuildContext context) {
    double targetLat = 0.0;
    double targetLng = 0.0;
    String targetName = "";

    // 1. Tenta pegar da RESERVA (O ideal: dados salvos no momento do booking)
    if (widget.booking.pickupLat != null && widget.booking.pickupLat != 0.0) {
      targetLat = widget.booking.pickupLat!;
      targetLng = widget.booking.pickupLng!;
      // Usa o endereço salvo, ou faz fallback para o nome da origem
      targetName = widget.booking.pickupAddress ?? widget.booking.originName;
    }
    // 2. FALLBACK: Tenta pegar da TRIP vinculada (Se os dados da reserva estiverem corrompidos/antigos)
    else if (widget.booking.trip != null) {
      final trip = widget.booking.trip!;

      // Lógica de recuperação inteligente (Igual à da criação):
      // Verifica se a origem da reserva (ex: "Cidade B") é um waypoint na Trip
      bool foundWaypoint = false;
      final bookingOriginName = widget.booking.originName.toLowerCase().trim();

      if (trip.waypoints.isNotEmpty) {
        for (var wp in trip.waypoints) {
          final wpName = wp.placeName.toLowerCase().trim();

          if (wpName.isNotEmpty && bookingOriginName.contains(wpName)) {
            // É um waypoint! Pega as coordenadas dele
            if (wp.boardingLat != null && wp.boardingLat != 0.0) {
              targetLat = wp.boardingLat!;
              targetLng = wp.boardingLng!;
              targetName = wp.boardingPlaceName ?? wp.placeName;
            } else {
              targetLat = wp.latitude;
              targetLng = wp.longitude;
              targetName = wp.placeName;
            }
            foundWaypoint = true;
            break;
          }
        }
      }

      // Se não achou nos waypoints, usa a origem raiz da viagem (Ponto A)
      if (!foundWaypoint) {
        targetLat = trip.originLat ?? 0.0;
        targetLng = trip.originLng ?? 0.0;
        targetName = trip.originName ?? widget.booking.originName;
      }
    }
    // 3. Fallback final (apenas nome)
    else {
      targetName = widget.booking.originName;
    }

    // Validação final
    if (targetLat == 0.0 || targetLng == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "A localização exata não está disponível para visualização.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BoardingLocationSheet(
          locationName: targetName,
          latitude: targetLat,
          longitude: targetLng,
        );
      },
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancelar Viagem?"),
        content: const Text(
          "Tem certeza que deseja cancelar esta solicitação?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Não", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);

              if (widget.booking.id != null) {
                _bookingCubit.cancelBooking(widget.booking.id!);
              }
            },
            child: const Text(
              "Sim, Cancelar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookingCubit,
      child: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingLoading) {
            // Opcional: Mostrar um loading overlay
          } else if (state is BookingCancelled) {
            // SUCESSO!
            setState(() {
              _currentStatus = 'cancelled'; // Atualiza a tela para VERMELHO
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is BookingError) {
            // ERRO
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text("Detalhes da Viagem"),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status e Data
                _buildStatusAndDateCard(),
                const SizedBox(height: 16),

                // 2. Stepper da Rota (Origem -> Destino)
                _buildRouteStepper(),
                const SizedBox(height: 16),

                // 3. Local de Embarque (Com botão de GPS)
                _buildPickupLocationCard(),
                const SizedBox(height: 16),

                // 4. Preço e Pagamento
                _buildPriceAndPaymentCard(),
                const SizedBox(height: 16),

                // 5. Informações do Motorista
                _buildDriverInfoCard(),
                const SizedBox(height: 30),

                // 6. Botões de Ação (Pagar / Cancelar)
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusAndDateCard() {
    // Prioridade total para a data da VIAGEM (departureTime).
    // Usamos o 'createdAt' apenas como último recurso de segurança para o app não quebrar.
    final tripDate = widget.booking.trip?.departureTime;
    final bookingDate = widget.booking.createdAt;
    // Data principal: Quando a viagem vai acontecer
    final mainDate = tripDate ?? bookingDate ?? DateTime.now();
    // Formato da Data: "Segunda-feira, 02 de Janeiro"
    final formattedDate = DateFormat(
      "EEEE, d 'de' MMMM",
      "pt_BR",
    ).format(mainDate);
    // Capitaliza a primeira letra da data
    final formattedDateCapitalized = formattedDate.replaceFirst(
      formattedDate[0],
      formattedDate[0].toUpperCase(),
    );

    // Formato da Hora: "14:30"
    final formattedTime = DateFormat("HH:mm").format(mainDate);

    Color statusColor = Colors.orange;
    String statusText = "Pendente";

    if (_currentStatus == 'approved') {
      statusColor = Colors.green;
      statusText =
          "Confirmada"; // "Aprovada" soa muito burocrático, "Confirmada" é melhor para UX
    } else if (_currentStatus == 'cancelled') {
      statusColor = Colors.red;
      statusText = "Cancelada";
    }

    // 4. Lógica da Contagem Regressiva
    final now = DateTime.now();
    final difference = mainDate.difference(now);

    String countdownText;
    IconData countdownIcon = Icons.timer_outlined;
    Color countdownColor = Colors.grey.shade600;

    if (difference.isNegative) {
      // Se a data já passou
      countdownText = "Viagem\nIniciada";
      countdownIcon = Icons.check_circle_outline;
      countdownColor = Colors.green;
    } else if (difference.inDays > 1) {
      countdownText = "Faltam\n${difference.inDays} dias";
    } else if (difference.inDays == 1) {
      countdownText = "Falta\n1 dia";
    } else if (difference.inHours > 0) {
      countdownText = "Faltam\n${difference.inHours} horas";
      countdownColor = Colors.blue.shade700;
    } else if (difference.inMinutes > 0) {
      countdownText = "Em\nbreve";
      countdownColor = Colors.red.shade400;
      countdownIcon = Icons.departure_board;
    } else {
      countdownText = "Agora";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withAlpha(51)),
                  ),
                  child: Text(
                    statusText.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Hora Grande
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    height: 1.0,
                    letterSpacing: -2.0,
                  ),
                ),
                const SizedBox(height: 4),

                // Data
                Text(
                  formattedDateCapitalized,
                  style: TextStyle(
                    fontSize: 14, // Levemente menor para não brigar com o resto
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Alinha tudo à direita
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: countdownColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(countdownIcon, color: countdownColor, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                countdownText.toUpperCase(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: countdownColor,
                  height:
                      1.2, // Espaçamento entre as linhas do "Faltam \n X Dias"
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStepper() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Origem
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: Colors.blue, size: 12),
                  Container(width: 2, height: 30, color: Colors.grey[300]),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ORIGEM",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.booking.originName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Destino
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 14,
              ), // Ícone um pouco maior para alinhar visualmente
              const SizedBox(width: 10), // Ajuste fino
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "DESTINO",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.booking.destinationName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupLocationCard() {
    final displayAddress =
        widget.booking.pickupAddress ?? widget.booking.originName;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(51)),
        boxShadow: [
          BoxShadow(color: Colors.blue.withAlpha(13), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Local de Embarque",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              InkWell(
                onTap: () => _showPickupLocationModal(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.map, color: Colors.blue, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.near_me, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayAddress,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 26),
            child: Text(
              "Toque no ícone do mapa para abrir no GPS",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndPaymentCard() {
    IconData paymentIcon = Icons.attach_money;
    String paymentText = "Dinheiro";

    if (widget.booking.paymentMethod == 'pix') {
      paymentIcon = Icons.pix;
      paymentText = "PIX";
    } else if (widget.booking.paymentMethod == 'credit_card') {
      paymentIcon = Icons.credit_card;
      paymentText = "Cartão";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Valor Total", style: TextStyle(color: Colors.grey)),
              Text(
                _currencyFormat.format(widget.booking.totalPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          Row(
            children: [
              Icon(paymentIcon, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                "Pagamento via $paymentText",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    final driverName = widget.booking.driverProfile?.fullName ?? "Motorista";
    // Placeholder para foto (futuramente virá do profile)

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: Text(
              driverName[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Motorista",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  driverName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // Aqui podemos adicionar modelo do carro futuramente
                const Text(
                  "Ver perfil completo",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // Se estiver aprovada, mostra botão de Pagar (Simulação)
    bool isApproved = _currentStatus == 'approved';
    bool isCancelled = _currentStatus == 'cancelled';

    if (isCancelled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Botão de Chat - Só aparece se estiver Aprovada
        if (isApproved)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Placeholder para futura implementação do Chat/Realtime
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Chat em tempo real será implementado em breve!",
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble, color: Colors.white),
                label: const Text(
                  "Conversar com Motorista",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blueAccent, // Cor distinta para comunicação
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),

        // Botão de Pagamento (Se aprovada)
        if (isApproved)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar para tela de pagamento ou exibir QR Code
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Fluxo de pagamento em breve"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Realizar Pagamento",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

        // Botão de Cancelar (Sempre visível se não estiver cancelada)
        if (widget.booking.status != 'cancelled')
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _confirmCancel(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Cancelar Solicitação",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }
}
