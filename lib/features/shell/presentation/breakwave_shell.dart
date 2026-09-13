// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_shell.dart
// Purpose: Bottom-tab shell for BreakWave.
// Notes: IOS-G2F wires the privacy session controller and fail-closed route gate.
// Notes: Full App lock renders no protected shell content before authentication.
// ------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/billing/breakwave_billing_qa_config.dart';
import '../../../core/performance/breakwave_performance_probe.dart';
import '../../../core/privacy_lock/privacy_destination.dart';
import '../../../core/privacy_lock/privacy_lock_composition.dart';
import '../../../core/privacy_lock/privacy_lock_mode.dart';
import '../../../core/privacy_lock/privacy_lock_store.dart';
import '../../../core/privacy_lock/privacy_route_policy.dart';
import '../../../core/privacy_lock/privacy_session_controller.dart';
import '../../../core/privacy_lock/privacy_session_state.dart';
import '../../billing_qa/presentation/billing_qa_screen.dart';
import '../../guided_routines/domain/recovery_routine.dart';
import '../../home/presentation/home_screen.dart';
import '../../log/presentation/log_screen.dart';
import '../../personal_plan/presentation/personal_recovery_plan_screen.dart';
import '../../premium/presentation/breakwave_plus_access_button.dart';
import '../../premium/presentation/breakwave_plus_screen.dart';
import '../../privacy_lock/presentation/privacy_locked_screen.dart';
import '../../privacy_lock/presentation/privacy_unlock_screen.dart';
import '../../rescue/presentation/rescue_screen.dart';
import '../../support/presentation/support_screen.dart';

class BreakWaveShell extends StatefulWidget {
  const BreakWaveShell({
    super.key,
    this.privacySessionController,
    this.privacyPlatform,
  });

  final PrivacySessionController? privacySessionController;
  final PrivacyCredentialPlatform? privacyPlatform;

  @override
  State<BreakWaveShell> createState() => _BreakWaveShellState();
}

class _BreakWaveShellState extends State<BreakWaveShell>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _homeRefreshTick = 0;
  int _logRefreshTick = 0;

  late final PrivacyCredentialPlatform _privacyPlatform;
  late final PrivacySessionController _privacySessionController;
  late final bool _ownsPrivacySessionController;

  bool _privacyInitializing = true;
  PrivacySessionState _lastPrivacyState = PrivacySessionState.locked;

  @override
  void initState() {
    super.initState();

    _privacyPlatform = widget.privacyPlatform ?? _platformForCurrentTarget();
    _ownsPrivacySessionController = widget.privacySessionController == null;
    _privacySessionController = widget.privacySessionController ??
        PrivacyLockComposition.sessionControllerFor(
          platform: _privacyPlatform,
        );

    WidgetsBinding.instance.addObserver(this);
    _privacySessionController.addListener(_handlePrivacySessionChanged);

    if (_privacyPlatform == PrivacyCredentialPlatform.android) {
      PrivacyLockStore.changes.addListener(_handleLegacyLockSettingsChanged);
    }

    _initializePrivacySession();
  }

  @override
  void dispose() {
    if (_privacyPlatform == PrivacyCredentialPlatform.android) {
      PrivacyLockStore.changes.removeListener(_handleLegacyLockSettingsChanged);
    }
    _privacySessionController.removeListener(_handlePrivacySessionChanged);
    if (_ownsPrivacySessionController) {
      _privacySessionController.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  PrivacyCredentialPlatform _platformForCurrentTarget() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PrivacyCredentialPlatform.android;
      case TargetPlatform.iOS:
        return PrivacyCredentialPlatform.ios;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return PrivacyCredentialPlatform.unsupported;
    }
  }

  Future<void> _initializePrivacySession() async {
    if (mounted && !_privacyInitializing) {
      setState(() {
        _privacyInitializing = true;
      });
    }

    if (_privacyPlatform == PrivacyCredentialPlatform.iOS) {
      // IOS-G2F must not leave the released Android-era raw PIN record in
      // ordinary iOS app preferences. The iOS credential authority is Keychain.
      await PrivacyLockStore.clear();
    }

    await _privacySessionController.initialize();
    if (!mounted) return;

    _lastPrivacyState = _privacySessionController.state;
    setState(() {
      _privacyInitializing = false;
    });
  }

  void _handleLegacyLockSettingsChanged() {
    _initializePrivacySession();
  }

  void _handlePrivacySessionChanged() {
    final PrivacySessionState previous = _lastPrivacyState;
    final PrivacySessionState next = _privacySessionController.state;
    _lastPrivacyState = next;

    if (!mounted) return;
    setState(() {});

    if (previous == PrivacySessionState.unlocked &&
        next != PrivacySessionState.unlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_privacyInitializing || !_privacySessionController.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _privacySessionController.onResumed(DateTime.now());
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _privacySessionController.onBackgrounded(DateTime.now());
    }
  }

  PrivacyDestination _destinationForIndex(int index) {
    return switch (index) {
      0 => PrivacyDestination.home,
      1 => PrivacyDestination.rescuePersonalized,
      2 => PrivacyDestination.log,
      3 => PrivacyDestination.support,
      4 => PrivacyDestination.internalQa,
      _ => PrivacyDestination.unknown,
    };
  }

  int? _indexForDestination(PrivacyDestination destination) {
    return switch (destination) {
      PrivacyDestination.home => 0,
      PrivacyDestination.rescuePersonalized => 1,
      PrivacyDestination.log => 2,
      PrivacyDestination.support => 3,
      PrivacyDestination.internalQa => BreakWaveBillingQaConfig.enabled ? 4 : null,
      _ => null,
    };
  }

  bool _requiresAuthentication(PrivacyDestination destination) {
    if (_privacyInitializing || !_privacySessionController.isInitialized) {
      return true;
    }

    return PrivacyRoutePolicy.requiresAuthentication(
      destination: destination,
      lockMode: _privacySessionController.configuration.mode,
      sessionState: _privacySessionController.state,
    );
  }

  void _requestDestinationOrRun(
    PrivacyDestination destination,
    VoidCallback onAllowed,
  ) {
    if (_privacyInitializing || !_privacySessionController.isInitialized) {
      return;
    }

    if (_requiresAuthentication(destination)) {
      _privacySessionController.requestProtectedDestination(destination);
      return;
    }

    if (_privacySessionController.requestedProtectedDestination != null) {
      _privacySessionController.takeRequestedProtectedDestination();
    }
    onAllowed();
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

  void _selectDestination(int index) {
    if (_selectedIndex == index && index != 0 && index != 2) return;

    final int previousIndex = _selectedIndex;
    final Stopwatch? transitionTimer = BreakWavePerformanceProbe.enabled
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
              'tab_${_destinationPerformanceLabel(previousIndex)}_to_${_destinationPerformanceLabel(index)}',
          stopwatch: transitionTimer,
        );
      });
    }
  }

  void _onDestinationSelected(int index) {
    final PrivacyDestination destination = _destinationForIndex(index);
    _requestDestinationOrRun(destination, () => _selectDestination(index));
  }

  void _returnHome() {
    _onDestinationSelected(0);
  }

  void _pushPersonalPlan() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const PersonalRecoveryPlanScreen(),
      ),
    );
  }

  void _openPersonalPlan() {
    _requestDestinationOrRun(
      PrivacyDestination.personalPlan,
      _pushPersonalPlan,
    );
  }

  void _pushBreakWavePlus() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BreakWavePlusScreen(
          onRoutineActionRequested: _handleRoutineActionRequested,
        ),
      ),
    );
  }

  void _openBreakWavePlus() {
    _requestDestinationOrRun(
      PrivacyDestination.billing,
      _pushBreakWavePlus,
    );
  }

  void _handleRoutineActionRequested(RoutineActionTarget target) {
    final NavigatorState navigator = Navigator.of(context);

    switch (target) {
      case RoutineActionTarget.rescue:
        _requestDestinationOrRun(
          PrivacyDestination.rescuePersonalized,
          () {
            navigator.popUntil((Route<dynamic> route) => route.isFirst);
            _onDestinationSelected(1);
          },
        );
        return;

      case RoutineActionTarget.log:
        _requestDestinationOrRun(
          PrivacyDestination.log,
          () {
            navigator.popUntil((Route<dynamic> route) => route.isFirst);
            _onDestinationSelected(2);
          },
        );
        return;

      case RoutineActionTarget.support:
        _requestDestinationOrRun(
          PrivacyDestination.support,
          () {
            navigator.popUntil((Route<dynamic> route) => route.isFirst);
            _onDestinationSelected(3);
          },
        );
        return;

      case RoutineActionTarget.personalPlan:
        _requestDestinationOrRun(
          PrivacyDestination.personalPlan,
          _pushPersonalPlan,
        );
        return;
    }
  }

  void _requestUnlockFromLockedLanding({required bool fromRescueSafe}) {
    final PrivacyDestination destination = fromRescueSafe
        ? PrivacyDestination.rescuePersonalized
        : _destinationForIndex(_selectedIndex);
    _privacySessionController.requestProtectedDestination(destination);
  }

  Future<void> _enterRescueSafe() async {
    await _privacySessionController.enterRescueSafe();
  }

  void _handleUnlockCancelled() {
    _privacySessionController.authenticationCancelled();
    _privacySessionController.takeRequestedProtectedDestination();

    final PrivacyDestination current = _destinationForIndex(_selectedIndex);
    if (_requiresAuthentication(current) &&
        _privacySessionController.configuration.mode ==
            PrivacyLockMode.sensitiveSections) {
      _selectDestination(0);
    }
  }

  void _handleUnlockSuccess() {
    final PrivacyDestination? destination =
        _privacySessionController.takeRequestedProtectedDestination();

    if (destination == null) {
      setState(() {});
      return;
    }

    final int? index = _indexForDestination(destination);
    if (index != null) {
      _selectDestination(index);
      return;
    }

    switch (destination) {
      case PrivacyDestination.personalPlan:
        _pushPersonalPlan();
        return;
      case PrivacyDestination.billing:
        _pushBreakWavePlus();
        return;
      case PrivacyDestination.unknown:
        _privacySessionController.lockNow();
        return;
      case PrivacyDestination.lockedLanding:
      case PrivacyDestination.rescueSafe:
      case PrivacyDestination.personalWhy:
      case PrivacyDestination.insights:
      case PrivacyDestination.routineHistory:
      case PrivacyDestination.recoveryReport:
      case PrivacyDestination.privacySettings:
      case PrivacyDestination.trustedContact:
      case PrivacyDestination.exports:
        return;
      case PrivacyDestination.home:
      case PrivacyDestination.rescuePersonalized:
      case PrivacyDestination.log:
      case PrivacyDestination.support:
      case PrivacyDestination.internalQa:
        return;
    }
  }

  List<NavigationDestination> _navigationDestinations() {
    return <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.waves_outlined),
        selectedIcon: Icon(Icons.waves),
        label: 'Rescue',
      ),
      const NavigationDestination(
        icon: Icon(Icons.edit_note_outlined),
        selectedIcon: Icon(Icons.edit_note),
        label: 'Log',
      ),
      const NavigationDestination(
        icon: Icon(Icons.support_outlined),
        selectedIcon: Icon(Icons.support),
        label: 'Support',
      ),
      if (BreakWaveBillingQaConfig.enabled)
        const NavigationDestination(
          icon: Icon(Icons.science_outlined),
          selectedIcon: Icon(Icons.science),
          label: 'Billing QA',
        ),
    ];
  }

  Widget _privacyScaffold({
    required Widget body,
    required bool showNavigation,
  }) {
    return Scaffold(
      body: body,
      bottomNavigationBar: showNavigation
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: _navigationDestinations(),
            )
          : null,
    );
  }

  Widget _buildAllowedShell() {
    final bool canHome = !_requiresAuthentication(PrivacyDestination.home);
    final bool canRescue =
        !_requiresAuthentication(PrivacyDestination.rescuePersonalized);
    final bool canLog = !_requiresAuthentication(PrivacyDestination.log);
    final bool canSupport = !_requiresAuthentication(PrivacyDestination.support);
    final bool canInternalQa =
        !_requiresAuthentication(PrivacyDestination.internalQa);

    final List<Widget> screens = <Widget>[
      canHome
          ? HomeScreen(
              refreshTick: _homeRefreshTick,
              onOpenRescue: () => _onDestinationSelected(1),
              onOpenLog: () => _onDestinationSelected(2),
              onOpenPersonalPlan: _openPersonalPlan,
            )
          : const SizedBox.shrink(),
      canRescue
          ? RescueScreen(
              onReturnHome: _returnHome,
              onOpenSupport: () => _onDestinationSelected(3),
              onOpenLog: () => _onDestinationSelected(2),
            )
          : const SizedBox.shrink(),
      canLog
          ? LogScreen(
              refreshTick: _logRefreshTick,
              onReturnHome: _returnHome,
              onOpenRescue: () => _onDestinationSelected(1),
              onOpenSupport: () => _onDestinationSelected(3),
            )
          : const SizedBox.shrink(),
      canSupport
          ? SupportScreen(
              onRoutineActionRequested: _handleRoutineActionRequested,
            )
          : const SizedBox.shrink(),
      if (BreakWaveBillingQaConfig.enabled)
        canInternalQa ? const BillingQaScreen() : const SizedBox.shrink(),
    ];

    final bool showCustomerPlusAccess = _selectedIndex < 4;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
          ),
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
        destinations: _navigationDestinations(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_privacyInitializing || !_privacySessionController.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final PrivacyLockMode mode =
        _privacySessionController.configuration.mode;
    final PrivacySessionState state = _privacySessionController.state;
    final PrivacyDestination? requested =
        _privacySessionController.requestedProtectedDestination;
    final PrivacyDestination current = _destinationForIndex(_selectedIndex);
    final bool currentRequiresAuthentication =
        _requiresAuthentication(current);
    final bool showingAuthentication =
        requested != null ||
            state == PrivacySessionState.authenticating ||
            (mode == PrivacyLockMode.sensitiveSections &&
                currentRequiresAuthentication);

    final bool fullAppLocked =
        mode == PrivacyLockMode.fullApp &&
            state != PrivacySessionState.unlocked;

    if (fullAppLocked) {
      if (showingAuthentication) {
        return _privacyScaffold(
          showNavigation: false,
          body: PrivacyUnlockScreen(
            controller: _privacySessionController,
            onUnlocked: _handleUnlockSuccess,
            onCancelled: _handleUnlockCancelled,
          ),
        );
      }

      if (state == PrivacySessionState.rescueSafe) {
        return _privacyScaffold(
          showNavigation: false,
          body: PrivacyLockedScreen(
            rescueSafeActive: true,
            onUnlock: () => _requestUnlockFromLockedLanding(
              fromRescueSafe: true,
            ),
            onOpenRescue: _enterRescueSafe,
            onBackToLock: _privacySessionController.lockNow,
          ),
        );
      }

      return _privacyScaffold(
        showNavigation: false,
        body: PrivacyLockedScreen(
          onUnlock: () => _requestUnlockFromLockedLanding(
            fromRescueSafe: false,
          ),
          onOpenRescue: _enterRescueSafe,
        ),
      );
    }

    if (showingAuthentication) {
      return _privacyScaffold(
        showNavigation: mode == PrivacyLockMode.sensitiveSections,
        body: PrivacyUnlockScreen(
          controller: _privacySessionController,
          onUnlocked: _handleUnlockSuccess,
          onCancelled: _handleUnlockCancelled,
        ),
      );
    }

    return _buildAllowedShell();
  }
}
