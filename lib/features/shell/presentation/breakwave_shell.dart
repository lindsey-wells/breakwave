/// ------------------------------------------------------------
/// Cube23 Collaboration Header
/// Project: BreakWave
/// File: breakwave_shell.dart
/// Purpose: Bottom-tab shell for the first BreakWave navigation pass.
/// Notes: Shell-first deterministic scaffold for BW-02.
/// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../home/presentation/home_screen.dart';
import '../../log/presentation/log_screen.dart';
import '../../rescue/presentation/rescue_screen.dart';
import '../../support/presentation/support_screen.dart';

class BreakWaveShell extends StatefulWidget {
  const BreakWaveShell({super.key});

  @override
  State<BreakWaveShell> createState() => _BreakWaveShellState();
}

class _BreakWaveShellState extends State<BreakWaveShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      HomeScreen(
        onOpenRescue: () => _onDestinationSelected(1),
        onOpenLog: () => _onDestinationSelected(2),
      ),
      const RescueScreen(),
      const LogScreen(),
      const SupportScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.waves_outlined),
            selectedIcon: Icon(Icons.waves),
            label: 'Rescue',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_outlined),
            selectedIcon: Icon(Icons.support),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}
