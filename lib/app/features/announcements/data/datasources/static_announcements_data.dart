import 'package:flutter/material.dart';
import 'package:plumo/app/features/announcements/data/models/announcement_model.dart';

class StaticAnnouncementsData {
  static List<AnnouncementModel> getDefaults(String role) {
    final List<AnnouncementModel> list = [];

    // Aviso Genérico 1
    list.add(
      const AnnouncementModel(
        title: 'Bem-vindo ao Plumo!',
        message: 'Encontre as melhores caronas com segurança e economia.',
        color: Color(0xFF1E88E5), // Azul
        icon: Icons.waving_hand,
        priority: 10,
        type: 'static',
      ),
    );

    // Aviso Específico para Motorista
    if (role == 'driver') {
      list.add(
        const AnnouncementModel(
          title: 'Ganhe Renda Extra',
          message: 'Cadastre sua próxima viagem e comece a economizar.',
          color: Color(0xFF43A047), // Verde
          icon: Icons.attach_money,
          priority: 11,
          type: 'static',
          actionUrl: '/create-trip', // Exemplo de rota
        ),
      );
    }

    // Aviso Específico para Passageiro
    if (role == 'passenger') {
      list.add(
        const AnnouncementModel(
          title: 'Dica de Segurança',
          message:
              'Sempre verifique a avaliação do motorista antes de reservar.',
          color: Color(0xFFFB8C00), // Laranja
          icon: Icons.security,
          priority: 12,
          type: 'static',
        ),
      );
    }

    return list;
  }
}
