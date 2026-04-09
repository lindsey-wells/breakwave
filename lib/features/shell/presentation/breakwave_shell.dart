// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_shell.dart
// Purpose: Bottom-tab shell for BreakWave.
// Notes: BW-41 adds privacy lock gating and relock-on-background.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/privacy_lock/privacy_lock_mode.dart';
import '../../../core/privacy_lock/privacy_lock_settings.dart';
import '../../../core/privacy_lock/privacy_lock_store.dart';
import '../../home/presentation/home_screen.dart';
import '../../log/presentation/log_screen.dart';
import '../../privacy_lock/presentation/privacy_unlock_screen.dart';
import '../../rescue/presentation/rescue_screen.dart';
import '../../support/presentation/support_screen.dart';

class BreakWaveShell extends StatefulWidget {
  const BreakWaveShell({super.key});

  @override
  State<BreakWaveShell> createState() => _BreakWaveShellState();
}

class _BreakWaveShellState extends State<BreakWaveShell>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _homeRefreshTick = 0;
  int _logRefreshTick = 0;

  bool _lockLoading = true;
  bool _sessionUnlocked = false;
  PrivacyLockSettings _lockSettings = PrivacyLockSettings.defaults;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PrivacyLockStore.changes.addListener(_handleLockSettingsChanged);
    _loadLockSettings();
  }

  @override
  void dispose() {
    PrivacyLockStore.changes.removeListener(_handleLockSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_lockSettings.isEnabled) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      setState(() {
        _sessionUnlocked = false;
      });
    }
  }

  Future<void> _loadLockSettings() async {
    final PrivacyLockSettings settings = await PrivacyLockStore.load();
    if (!mounted) return;

    setState(() {
      final bool lockChanged =
          settings.mode != _lockSettings.mode ||
          settings.passcode != _lockSettings.passcode;

      _lockSettings = settings;
      _lockLoading = false;

      if (!settings.isEnabled) {
        _sessionUnlocked = false;
      } else if (lockChanged) {
        _sessionUnlocked = false;
      }
    });
  }

  void _handleLockSettingsChanged() {
    _loadLockSettings();
  }

  bool _shouldShowLockScreen() {
    if (_lockLoading || !_lockSettings.isEnabled || _sessionUnlocked) {
      return false;
    }

    switch (_lockSettings.mode) {
      case PrivacyLockMode.fullApp:
        return true;
      case PrivacyLockMode.sensitiveSections:
        return _selectedIndex == 2 || _selectedIndex == 3;
      case PrivacyLockMode.none:
        return false;
    }
  }

  void _handleUnlocked() {
    setState(() {
      _sessionUnlocked = true;
    });
  }

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index && index != 0 && index != 2) return;

    setState(() {
      if (index == 0) {
        _homeRefreshTick += 1;
      }
      if (index == 2) {
        _logRefreshTick += 1;
      }
      _selectedIndex = index;
    });
  }

  void _returnHome() {
    setState(() {
      _homeRefreshTick += 1;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      HomeScreen(
        key: ValueKey<int>(_homeRefreshTick),
        onOpenRescue: () => _onDestinationSelected(1),
        onOpenLog: () => _onDestinationSelected(2),
      ),
      RescueScreen(
        onReturnHome: _returnHome,
      ),
      LogScreen(
        key: ValueKey<int>(_logRefreshTick),
        onReturnHome: _returnHome,
      ),
      const SupportScreen(),
    ];

    return Scaffold(
      body: _lockLoading
          ? const Center(child: CircularProgressIndicator())
          : _shouldShowLockScreen()
              ? PrivacyUnlockScreen(
                  settings: _lockSettings,
                  onUnlocked: _handleUnlocked,
                )
              : IndexedStack(
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
