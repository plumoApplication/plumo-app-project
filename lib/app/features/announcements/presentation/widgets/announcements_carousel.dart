import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plumo/app/features/announcements/data/models/announcement_model.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir links externos

class AnnouncementsCarousel extends StatefulWidget {
  final List<AnnouncementModel> announcements;

  const AnnouncementsCarousel({super.key, required this.announcements});

  @override
  State<AnnouncementsCarousel> createState() => _AnnouncementsCarouselState();
}

class _AnnouncementsCarouselState extends State<AnnouncementsCarousel> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.announcements.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_currentPage < widget.announcements.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  // Lógica de Clique
  void _handleTap(AnnouncementModel item) {
    if (item.actionUrl != null && item.actionUrl!.isNotEmpty) {
      final url = item.actionUrl!;
      if (url.startsWith('http')) {
        // Link Externo
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        // Rota Interna (Ex: '/wallet')
        Navigator.pushNamed(context, url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se a lista estiver vazia, esconde o widget (segurança)
    if (widget.announcements.isEmpty) return const SizedBox.shrink();

    final bool isAllStatic = widget.announcements.first.type == 'static';
    final double height = isAllStatic ? 100 : 150;

    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemCount: widget.announcements.length,
        itemBuilder: (context, index) {
          final item = widget.announcements[index];
          return GestureDetector(
            onTap: () => _handleTap(item),
            child: _buildContentSelector(item),
          );
        },
      ),
    );
  }

  Widget _buildContentSelector(AnnouncementModel item) {
    if (item.type == 'static') {
      return _buildNativeStyle(item);
    } else {
      return _buildCardStyle(item);
    }
  }

  Widget _buildNativeStyle(AnnouncementModel item) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 26, // [AJUSTE] Fonte bem grande e grossa
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              // Ícone opcional e discreto ao lado do título (se quiser remover, apague este if)
              if (item.icon != Icons.info_outline) ...[
                const SizedBox(width: 8),
                Icon(item.icon, color: item.color, size: 28),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCardStyle(AnnouncementModel item) {
    // Definição da Imagem de Fundo (se houver)
    final imageDecoration = item.imageUrl != null && item.imageUrl!.isNotEmpty
        ? DecorationImage(
            image: NetworkImage(item.imageUrl!),
            fit: BoxFit.cover,
          )
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: item.imageUrl != null ? Colors.transparent : item.color,
        borderRadius: BorderRadius.circular(16),
        image: imageDecoration,
      ),

      child: _buildCardInterior(item),
    );
  }

  Widget _buildCardInterior(AnnouncementModel item) {
    // CASO A: Banner de Imagem
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return const SizedBox(height: double.infinity);
      // Dica: Se quiser texto em cima da imagem futuramente, coloque aqui.
    }

    // CASO B: Card Colorido Padrão
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (item.actionUrl != null)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
