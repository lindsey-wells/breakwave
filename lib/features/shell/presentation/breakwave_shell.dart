// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_shell.dart
// Purpose: Bottom-tab shell for BreakWave.
// Notes: BW-41 adds privacy lock gating and relock-on-background.
// Notes: BW-87B4C connects guided routines to real app destinations.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/billing/breakwave_billing_qa_config.dart';
import '../../../core/performance/breakwave_performance_probe.dart';
import '../../../core/privacy_lock/privacy_lock_mode.dart';
import '../../../core/privacy_lock/privacy_lock_settings.dart';
import '../../../core/privacy_lock/privacy_lock_store.dart';
import '../../billing_qa/presentation/billing_qa_screen.dart';
import '../../guided_routines/domain/recovery_routine.dart';
import '../../home/presentation/home_screen.dart';
import '../../log/presentation/log_screen.dart';
import '../../personal_plan/presentation/personal_recovery_plan_screen.dart';
import '../../premium/presentation/breakwave_plus_access_button.dart';
import '../../premium/presentation/breakwave_plus_screen.dart';
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

  static const Duration _privacyRelockGracePeriod = Duration(minutes: 2);

  bool _lockLoading = true;
  bool _sessionUnlocked = false;
  DateTime? _privacyLockBackgroundedAt;
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

    if (state == AppLifecycleState.resumed) {
      _handleAppResumedForPrivacyLock();
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _privacyLockBackgroundedAt ??= DateTime.now();
    }
  }

  void _handleAppResumedForPrivacyLock() {
    final DateTime? backgroundedAt = _privacyLockBackgroundedAt;
    _privacyLockBackgroundedAt = null;

    if (backgroundedAt == null) return;

    final Duration awayFor = DateTime.now().difference(backgroundedAt);
    if (awayFor < _privacyRelockGracePeriod) return;

    if (!mounted) return;

    setState(() {
      _sessionUnlocked = false;
    });
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
        _privacyLockBackgroundedAt = null;
        _sessionUnlocked = false;
      } else if (lockChanged) {
        _privacyLockBackgroundedAt = null;
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
      _privacyLockBackgroundedAt = null;
      _sessionUnlocked = true;
    });
  }

  String _destinationPerformanceLabel(int index) {
    return switch (index) {
      0 => 'home',
      1 => 'rescue',
      2 => 'log',
      3 => 'support',
      4 => 'billing_qa',
      _ => 'unknown_$index',
    };
  }

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index && index != 0 && index != 2) return;

    final int previousIndex = _selectedIndex;
    final Stopwatch? transitionTimer =
        BreakWavePerformanceProbe.enabled
            ? BreakWavePerformanceProbe.startTimer()
            : null;

    setState(() {
      if (index == 0) {
        _homeRefreshTick += 1;
      }
      if (index == 2) {
        _logRefreshTick += 1;
      }
      _selectedIndex = index;
    });

    if (transitionTimer != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BreakWavePerformanceProbe.recordElapsed(
          category: 'tab',
          name:
              'tab_${_destinationPerformanceLabel(previousIndex)}'
              '_to_${_destinationPerformanceLabel(index)}',
          stopwatch: transitionTimer,
        );
      });
    }
  }

  void _returnHome() {
    setState(() {
      _homeRefreshTick += 1;
      _selectedIndex = 0;
    });
  }

  void _handleRoutineActionRequested(
    RoutineActionTarget target,
  ) {
    final NavigatorState navigator =
        Navigator.of(context);

    switch (target) {
      case RoutineActionTarget.rescue:
        navigator.popUntil(
          (Route<dynamic> route) => route.isFirst,
        );
        _onDestinationSelected(1);
        return;

      case RoutineActionTarget.log:
        navigator.popUntil(
          (Route<dynamic> route) => route.isFirst,
        );
        _onDestinationSelected(2);
        return;

      case RoutineActionTarget.support:
        navigator.popUntil(
          (Route<dynamic> route) => route.isFirst,
        );
        _onDestinationSelected(3);
        return;

      case RoutineActionTarget.personalPlan:
        navigator.push<void>(
          MaterialPageRoute<void>(
            builder: (_) =>
                const PersonalRecoveryPlanScreen(),
          ),
        );
        return;
    }
  }


  void _openBreakWavePlus() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BreakWavePlusScreen(
          onRoutineActionRequested:
              _handleRoutineActionRequested,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = <Widget>[
      HomeScreen(
        refreshTick: _homeRefreshTick,
        onOpenRescue: () => _onDestinationSelected(1),
        onOpenLog: () => _onDestinationSelected(2),
        onOpenPersonalPlan: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const PersonalRecoveryPlanScreen(),
          ),
        ),
      ),
      RescueScreen(
        onReturnHome: _returnHome,
        onOpenSupport: () => _onDestinationSelected(3),
        onOpenLog: () => _onDestinationSelected(2),
      ),
      LogScreen(
        refreshTick: _logRefreshTick,
        onReturnHome: _returnHome,
        onOpenRescue: () => _onDestinationSelected(1),
        onOpenSupport: () => _onDestinationSelected(3),
      ),
      SupportScreen(
        onRoutineActionRequested:
            _handleRoutineActionRequested,
      ),
      if (BreakWaveBillingQaConfig.enabled)
        const BillingQaScreen(),
    ];

    final bool showLockScreen = _shouldShowLockScreen();
    final bool showCustomerPlusAccess =
        !_lockLoading &&
        !showLockScreen &&
        _selectedIndex != 1 &&
        _selectedIndex < 4;

    final Widget shellBody = _lockLoading
        ? const Center(child: CircularProgressIndicator())
        : showLockScreen
            ? PrivacyUnlockScreen(
                settings: _lockSettings,
                onUnlocked: _handleUnlocked,
              )
            : IndexedStack(
                index: _selectedIndex,
                children: screens,
              );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: shellBody),
          if (showCustomerPlusAccess)
            Positioned(
              top: 10,
              right: 12,
              child: SafeArea(
                child: BreakWavePlusAccessButton(
                  onPressed: _openBreakWavePlus,
                ),
              ),
            ),
        ],
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
          if (BreakWaveBillingQaConfig.enabled)
            NavigationDestination(
              icon: Icon(Icons.science_outlined),
              selectedIcon: Icon(Icons.science),
              label: 'Billing QA',
            ),
        ],
      ),
    );
  }
}
