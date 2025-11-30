import 'package:flutter/material.dart';

class AnnouncementModel {
  final String title;
  final String message;
  final Color color;
  final IconData icon;

  const AnnouncementModel({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    // 1. Converte a String HEX (ex: "0xFF1E88E5") para Color
    String hexString = map['color_hex'] ?? '0xFF2196F3';
    // Garante que a string tenha o tamanho certo para evitar erros
    if (hexString.length != 10) hexString = '0xFF2196F3';

    Color color;
    try {
      color = Color(int.parse(hexString));
    } catch (e) {
      color = Colors.blue;
    }

    // 2. Mapeia o nome do ícone para IconData
    String iconName = map['icon_name'] ?? 'info';
    IconData icon;
    switch (iconName) {
      case 'security':
        icon = Icons.security;
        break;
      case 'offer':
        icon = Icons.local_offer;
        break;
      case 'map':
        icon = Icons.map;
        break;
      case 'warning':
        icon = Icons.warning_amber_rounded;
        break;
      case 'notification':
        icon = Icons.notifications_active;
        break;
      default:
        icon = Icons.info_outline;
    }

    return AnnouncementModel(
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      color: color,
      icon: icon,
    );
  }
}
