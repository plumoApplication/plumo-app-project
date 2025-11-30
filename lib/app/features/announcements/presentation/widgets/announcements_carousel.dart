import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plumo/app/features/announcements/data/models/announcement_model.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < widget.announcements.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: widget.announcements.length,
        itemBuilder: (context, index) {
          final item = widget.announcements[index];
          return _buildAnnouncementCard(item);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel item) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ), // Margem lateral ajustada
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: 32),
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
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
