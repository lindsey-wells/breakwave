// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: practice_rescue_screen.dart
// Purpose: Sandboxed Rescue practice with no recovery side effects.
// Notes: BW-ONBOARD-01B2 does not save, message, call, log, or navigate to Support.
// ------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/recovery/recovery_mode.dart';
import '../../../core/recovery/recovery_mode_store.dart';
import '../../../core/ui/section_header.dart';
import '../../../core/ui/wave_surface.dart';
import '../../../core/why/custom_why_entry.dart';
import '../../../core/why/custom_why_store.dart';
import '../../rescue/presentation/widgets/calm_reset_card.dart';
import '../../rescue/presentation/widgets/urge_intensity_section.dart';

class PracticeRescueScreen extends StatefulWidget {
  const PracticeRescueScreen({super.key});

  @override
  State<PracticeRescueScreen> createState() =>
      _PracticeRescueScreenState();
}

class _PracticeRescueScreenState extends State<PracticeRescueScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _whyKey = GlobalKey();

  bool _loading = true;
  int _selectedIntensity = 3;
  String? _selectedAction;
  RecoveryMode _mode = RecoveryMode.secular;
  CustomWhyEntry _why = CustomWhyEntry.empty;

  static const List<String> _baseActions = <String>[
    'Put the phone down',
    'Leave the room',
    'Open your why',
    'Text someone safe',
    'Cold water reset',
    'Take a short walk',
  ];

  @override
  void initState() {
    super.initState();
    _loadPracticeContext();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPracticeContext() async {
    try {
      final RecoveryMode mode =
          await RecoveryModeStore.loadMode() ?? RecoveryMode.secular;
      final CustomWhyEntry why = await CustomWhyStore.load();

      if (!mounted) return;
      setState(() {
        _mode = mode;
        _why = why;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  List<String> get _actions {
    if (_mode == RecoveryMode.christian) {
      return const <String>[
        ..._baseActions,
        'Pray for one minute',
      ];
    }
    return _baseActions;
  }

  Future<void> _scrollToWhy() async {
    final BuildContext? target = _whyKey.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _selectAction(String action) {
    setState(() {
      _selectedAction = action;
    });

    if (action == 'Open your why') {
      _scrollToWhy();
    }

    final String message = action == 'Text someone safe'
        ? 'Practice only. No message was opened.'
        : 'Practice selection only. Nothing was saved.';

    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _finishPractice() {
    Navigator.of(context).pop(true);
  }

  void _exitPractice() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Rescue — No Save'),
        actions: <Widget>[
          TextButton(
            key: const Key('practice-rescue-exit'),
            onPressed: _exitPractice,
            child: const Text('Exit practice'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                key: const Key('practice-rescue-scroll'),
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        WaveSurface(
                          key: const Key('practice-rescue-safety-banner'),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'PRACTICE MODE',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Learn the Rescue flow without changing your recovery record.',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No Log entry, insight, streak, plan, Personal Why, message, call, or emergency action will be created or opened.',
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Recognize → Interrupt → Redirect → Reinforce',
                                key: Key('practice-rescue-recovery-model'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Notice it → Break it → Choose differently → Strengthen what works',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SectionHeader(
                          eyebrow: 'Recognize • Practice step 1',
                          title: 'Notice the wave',
                        ),
                        UrgeIntensitySection(
                          selectedIntensity: _selectedIntensity,
                          onSelected: (int value) {
                            setState(() {
                              _selectedIntensity = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        const SectionHeader(
                          eyebrow: 'Interrupt • Practice step 2',
                          title: 'Bring your Personal Why into view',
                        ),
                        KeyedSubtree(
                          key: _whyKey,
                          child: _PracticeWhyCard(why: _why),
                        ),
                        const SizedBox(height: 20),
                        const SectionHeader(
                          eyebrow: 'Interrupt • Practice step 3',
                          title: 'Slow the body',
                        ),
                        const CalmResetCard(),
                        const SizedBox(height: 20),
                        const SectionHeader(
                          eyebrow: 'Redirect • Practice step 4',
                          title: 'Choose one next right action',
                        ),
                        _PracticeActionCard(
                          actions: _actions,
                          selectedAction: _selectedAction,
                          onSelected: _selectAction,
                        ),
                        const SizedBox(height: 20),
                        _PracticeFinishCard(
                          intensity: _selectedIntensity,
                          selectedAction: _selectedAction,
                          onFinish: _finishPractice,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _PracticeWhyCard extends StatelessWidget {
  const _PracticeWhyCard({required this.why});

  final CustomWhyEntry why;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Personal Why — read-only practice',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const Icon(Icons.visibility_outlined),
              ],
            ),
            const SizedBox(height: 10),
            if (!why.hasAnyContent)
              const Text(
                'In a real Rescue, your saved message or image appears here. For practice, imagine the person, promise, goal, faith commitment, or future you are protecting.',
              ),
            if (why.hasImage) ...<Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(why.imagePath),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (why.hasText)
              Text(
                why.whyText,
                style: theme.textTheme.bodyLarge,
              ),
            const SizedBox(height: 12),
            const Text(
              'Practice mode cannot edit or save your Personal Why.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeActionCard extends StatelessWidget {
  const _PracticeActionCard({
    required this.actions,
    required this.selectedAction,
    required this.onSelected,
  });

  final List<String> actions;
  final String? selectedAction;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Next Right Action — practice only',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Select an action to learn the decision point. External apps and Support actions are disabled here.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: actions.map((String action) {
                final bool selected = selectedAction == action;
                return ChoiceChip(
                  label: Text(action),
                  selected: selected,
                  showCheckmark: true,
                  selectedColor: colors.primary,
                  labelStyle: TextStyle(
                    color: selected ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => onSelected(action),
                );
              }).toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeFinishCard extends StatelessWidget {
  const _PracticeFinishCard({
    required this.intensity,
    required this.selectedAction,
    required this.onFinish,
  });

  final int intensity;
  final String? selectedAction;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Reinforce',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Practice summary',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Practice intensity: $intensity of 5'),
            const SizedBox(height: 6),
            Text(
              selectedAction == null
                  ? 'Choose a next right action to finish practice.'
                  : 'In a real moment, interrupting the old pattern and choosing $selectedAction is a response worth practicing.',
            ),
            const SizedBox(height: 14),
            const Text(
              'Finishing returns to the tour. Nothing from this practice is written to BreakWave.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('practice-rescue-finish'),
                onPressed: selectedAction == null ? null : onFinish,
                icon: const Icon(Icons.check_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Finish practice'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
