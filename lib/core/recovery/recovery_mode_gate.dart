import 'package:flutter/material.dart';

import '../../features/recovery_mode/recovery_mode_screen.dart';
import 'recovery_mode.dart';
import 'recovery_mode_store.dart';

class RecoveryModeGate extends StatefulWidget {
  const RecoveryModeGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<RecoveryModeGate> createState() => _RecoveryModeGateState();
}

class _RecoveryModeGateState extends State<RecoveryModeGate> {
  RecoveryMode? _mode;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final mode = await RecoveryModeStore.loadMode();
    if (!mounted) return;

    setState(() {
      _mode = mode;
      _loading = false;
    });
  }

  void _handleSaved(RecoveryMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_mode == null) {
      return RecoveryModeScreen(
        onSaved: _handleSaved,
      );
    }

    return widget.child;
  }
}
