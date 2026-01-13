import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

class TripDataCard extends StatefulWidget {
  final TripEntity trip;
  final VoidCallback onEditTap;

  const TripDataCard({super.key, required this.trip, required this.onEditTap});

  @override
  State<TripDataCard> createState() => _TripDataCardState();
}

class _TripDataCardState extends State<TripDataCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CABEÇALHO (SEMPRE VISÍVEL) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Dados da Viagem",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Indicador de Assentos (Sempre útil ver rápido)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_seat, size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.trip.availableSeats} assentos",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- STEPPER DINÂMICO ---
          // Usa IntrinsicHeight para que a linha cresça junto com o texto
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // COLUNA DA ESQUERDA (ÍCONES + LINHA)
                SizedBox(
                  width: 24, // Largura fixa para alinhar os ícones
                  child: Column(
                    children: [
                      // Ícone Origem
                      const Icon(
                        Icons.radio_button_checked,
                        size: 24,
                        color: Colors.green,
                      ),

                      // Linha que preenche o espaço automaticamente
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),

                      // Ícone Destino
                      const Icon(
                        Icons.location_on,
                        size: 24,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // COLUNA DA DIREITA (TEXTOS)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Texto Origem
                      _buildTextInfo(
                        label: "ORIGEM",
                        labelColor: Colors.green,
                        title: widget.trip.originName ?? "Cidade não informada",
                        subtitle: widget.trip.boardingPlaceName,
                        subtitlePrefix: "Local de embarque: ",
                      ),

                      // Espaço Mínimo entre textos (Define a altura mínima da linha)
                      const SizedBox(height: 18),

                      // Texto Destino
                      _buildTextInfo(
                        label: "DESTINO",
                        labelColor: Colors.red,
                        title:
                            widget.trip.destinationName ??
                            "Cidade não informada",
                        // Adicione subtitle aqui se o destino tiver local específico
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- CONTEÚDO EXPANDIDO (DETALHES) ---
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // --- RODAPÉ (BOTÕES) ---
          Row(
            children: [
              // Botão VER MAIS / VER MENOS
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                ),
                label: Text(
                  _isExpanded ? "Ver menos detalhes" : "Ver todos os dados",
                ),
              ),

              const Spacer(),

              // Botão EDITAR
              OutlinedButton.icon(
                onPressed: widget.onEditTap,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text("Editar", style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextInfo({
    required String label,
    required Color labelColor,
    required String title,
    String? subtitle,
    String? subtitlePrefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: labelColor, // Cor igual ao ícone
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13),
              children: [
                if (subtitlePrefix != null)
                  TextSpan(
                    text: subtitlePrefix,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                TextSpan(
                  text: subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedContent() {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // 1. WAYPOINTS (PONTOS DE PARADA)
        if (widget.trip.waypoints.isNotEmpty) ...[
          const Text(
            "PONTOS DE PARADA",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.trip.waypoints.map((wp) {
            final placeName = wp.boardingPlaceName ?? wp.placeName;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.place,
                      size: 14,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Parada ${wp.order}",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          placeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currency.format(wp.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // 2. DETALHAMENTO FINANCEIRO
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "RESUMO FINANCEIRO",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Preço Base
              _buildFinanceRow(
                "Valor Viagem, Destino - Origem",
                widget.trip.price,
                currency,
              ),

              // Taxa de Busca
              if (widget.trip.pickupFee > 0) ...[
                const SizedBox(height: 8),
                _buildFinanceRow(
                  "Taxa de Busca (Extra)",
                  widget.trip.pickupFee,
                  currency,
                  isGreen: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceRow(
    String label,
    double value,
    NumberFormat formatter, {
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        Text(
          formatter.format(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isGreen ? Colors.green[700] : Colors.black87,
          ),
        ),
      ],
    );
  }
}
