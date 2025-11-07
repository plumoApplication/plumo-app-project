import 'package:flutter/material.dart';
import 'package:plumo/app/features/my_trips/presentation/screens/my_trips_page.dart';
import 'package:plumo/app/features/profile/presentation/screens/profile_page.dart';
import 'package:plumo/app/features/trip_search/presentation/screens/trip_search_page.dart';

/// Este é o "Invólucro" (Shell) principal do passageiro.
/// Ele gerencia a barra de navegação inferior e
/// qual tela (aba) está sendo exibida.
class PassengerShell extends StatefulWidget {
  const PassengerShell({super.key});

  @override
  State<PassengerShell> createState() => _PassengerShellState();
}

class _PassengerShellState extends State<PassengerShell> {
  // Armazena o índice da aba atualmente selecionada
  int _selectedIndex = 0;

  // A lista de telas (abas) que o 'BottomNavigationBar' irá controlar
  // A ordem aqui DEVE corresponder à ordem dos itens da barra
  static const List<Widget> _pages = <Widget>[
    TripSearchPage(), // Aba 0 (Buscar)
    MyTripsPage(), // Aba 1 (Minhas Viagens)
    ProfilePage(), // Aba 2 (Perfil)
  ];

  // Função chamada quando o usuário toca em uma aba
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O 'body' (corpo) do Scaffold é a tela (página)
      // que está atualmente selecionada na lista '_pages'
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
        // (Usamos 'IndexedStack' em vez de '_pages[_selectedIndex]'
        //  pois ele preserva o estado das telas quando trocamos de aba.
        //  Ex: O usuário preenche a busca mas não clica,
        //      muda para a aba "Perfil" e depois volta,
        //      a busca dele ainda estará lá.)
      ),

      // A Barra de Navegação Inferior
      bottomNavigationBar: BottomNavigationBar(
        // Itens (abas)
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Minhas Viagens',
            // (No futuro, colocaremos o 'badge' de notificação aqui)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex, // Destaca a aba ativa
        onTap: _onItemTapped, // O que fazer ao tocar
        // (Podemos adicionar 'selectedItemColor' e 'unselectedItemColor'
        //  quando definirmos o tema do app)
      ),
    );
  }
}
