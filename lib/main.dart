import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/custom_plate_page.dart';
import 'pages/history_page.dart';

void main() {
  runApp(const FlouteMoiCaApp());
}

class FlouteMoiCaApp extends StatelessWidget {
  const FlouteMoiCaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floute Moi Ça',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final _pages = const [HomePage(), CustomPlatePage(), HistoryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Accueil'),
          NavigationDestination(
            icon: Icon(Icons.brush),
            label: 'Plaques perso',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
        ],
      ),
    );
  }
}
