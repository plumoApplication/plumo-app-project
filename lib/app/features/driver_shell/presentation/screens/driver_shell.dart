import 'package:plumo/app/features/driver_create_trip/presentation/screens/driver_create_trip_page.dart';
import 'package:plumo/app/features/driver_earnings/presentation/screens/driver_earnings_page.dart';
import 'package:plumo/app/features/driver_trips/presentation/screens/driver_trips_page.dart';
import 'package:plumo/app/features/trip_search/presentation/screens/trip_search_page.dart';
import 'package:plumo/app/features/profile/presentation/screens/profile_page.dart';
import 'package:flutter/material.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _selectedIndex = 0; // Começa na Aba 'Viagens' (índice 0)

  // A lista de 5 telas (abas)
  static const List<Widget> _pages = <Widget>[
    DriverTripsPage(), // Aba 0: Gerenciar Viagens
    TripSearchPage(userRole: 'driver'), // Aba 1: Buscar (Concorrência)
    DriverCreateTripPage(), // Aba 2: [+] Criar Viagem
    DriverEarningsPage(), // Aba 3: Ganhos
    ProfilePage(), // Aba 4: Perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        // Importante: para 5 abas, o tipo DEVE ser 'fixed'
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.drive_eta_outlined),
            label: 'Viagens',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 30), // Ícone central
            label: 'Criar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Ganhos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
