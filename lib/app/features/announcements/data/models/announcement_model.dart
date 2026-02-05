import 'package:flutter/material.dart';

class AnnouncementModel {
  final String title;
  final String message;
  final Color color;
  final IconData icon;

  // [NOVOS CAMPOS]
  final String? imageUrl; // Para banners de imagem
  final String? actionUrl; // Rota interna ou link externo
  final int priority; // 1 = Alta, 99 = Baixa
  final String type; // 'static', 'db_info', 'db_promo', 'db_alert', 'db_image'

  const AnnouncementModel({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    this.imageUrl,
    this.actionUrl,
    this.priority = 99,
    this.type = 'static',
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    // 1. Converter Hex para Color (Seguro)
    Color parseColor(String? hexString) {
      if (hexString == null || hexString.length != 10) {
        return const Color(0xFF2196F3);
      }
      try {
        return Color(int.parse(hexString));
      } catch (e) {
        return const Color(0xFF2196F3);
      }
    }

    // 2. Mapear Ícones (Expandido)
    IconData parseIcon(String? iconName) {
      switch (iconName) {
        case 'security':
          return Icons.security;
        case 'offer':
          return Icons.local_offer;
        case 'map':
          return Icons.map;
        case 'warning':
          return Icons.warning_amber_rounded;
        case 'notification':
          return Icons.notifications_active;
        case 'star':
          return Icons.star;
        case 'person':
          return Icons.person;
        default:
          return Icons.info_outline;
      }
    }

    return AnnouncementModel(
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      color: parseColor(map['color_hex']),
      icon: parseIcon(map['icon_name']),
      imageUrl: map['image_url'],
      actionUrl: map['action_route'],
      priority:
          map['priority'] ??
          1, // Se vier do banco, padrão é 1 (Alta prioridade)
      type: map['type'] ?? 'db_info',
    );
  }
}
