// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: personal_recovery_plan_body.dart
// Purpose: Presentation-only body for the Personal Recovery Plan screen.
// Notes: BW-MOD-01E extracts form markup without changing user behavior.
// ------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/recovery/recovery_mode.dart';
import '../personal_recovery_plan_draft_controllers.dart';
import 'personal_recovery_plan_widgets.dart';

class PersonalRecoveryPlanBody extends StatelessWidget {
  const PersonalRecoveryPlanBody({
    super.key,
    required this.loading,
    required this.loadError,
    required this.dirty,
    required this.sourceUpdateAvailable,
    required this.updatedLabel,
    required this.importing,
    required this.saving,
    required this.hasSavedPlan,
    required this.mode,
    required this.draftControllers,
    required this.reasonSuggestions,
    required this.triggerSuggestions,
    required this.dangerWindowSuggestions,
    required this.redirectSuggestions,
    required this.statusMessage,
    required this.onRetry,
    required this.onRefresh,
    required this.onSave,
  });

  final bool loading;
  final String? loadError;
  final bool dirty;
  final bool sourceUpdateAvailable;
  final String updatedLabel;
  final bool importing;
  final bool saving;
  final bool hasSavedPlan;
  final RecoveryMode mode;
  final PersonalRecoveryPlanDraftControllers draftControllers;
  final List<String> reasonSuggestions;
  final List<String> triggerSuggestions;
  final List<String> dangerWindowSuggestions;
  final List<String> redirectSuggestions;
  final String? statusMessage;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (loadError != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          PersonalPlanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const PersonalPlanSectionTitle('Plan unavailable'),
                const SizedBox(height: 10),
                Text(loadError!),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: <Widget>[
        PersonalPlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const PersonalPlanSectionTitle(
                'Build a plan you can actually use',
              ),
              const SizedBox(height: 10),
              const Text(
                'Connect what matters, what starts the wave, '
                'and what you will do next. Your plan stays '
                'on this device.',
              ),
              const SizedBox(height: 12),
              Text(
                dirty
                    ? 'Unsaved changes'
                    : sourceUpdateAvailable
                        ? 'New BreakWave choices are available'
                        : updatedLabel,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PersonalPlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const PersonalPlanSectionTitle(
                'Use my current BreakWave choices',
              ),
              const SizedBox(height: 8),
              const Text(
                'Refresh imported parts using your saved reasons, '
                'triggers, risky times, trusted support name, saved Why, '
                'and recent log patterns. Existing plan work will not be replaced.',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: importing ? null : onRefresh,
                  icon: const Icon(Icons.auto_fix_high),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Text(
                      importing
                          ? 'Refreshing plan...'
                          : 'Refresh from current BreakWave choices',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PersonalPlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const PersonalPlanSectionTitle('Why I am changing'),
              const SizedBox(height: 10),
              TextField(
                controller: draftControllers.primaryReason,
                decoration: const InputDecoration(
                  labelText: 'My main reason',
                  hintText:
                      'The reason I want in front of me first',
                ),
                textCapitalization:
                    TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              PersonalPlanListField(
                title: 'Reasons that matter',
                helper:
                    'Choose suggestions or enter one reason per line.',
                controller: draftControllers.reasons,
                suggestions: reasonSuggestions,
                onToggleSuggestion: (String value) =>
                    draftControllers.toggleSuggestion(
                  draftControllers.reasons,
                  value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PersonalPlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const PersonalPlanSectionTitle('What I need to watch'),
              const SizedBox(height: 12),
              PersonalPlanListField(
                title: 'Known triggers',
                helper:
                    'Choose suggestions or enter one trigger per line.',
                controller: draftControllers.triggers,
                suggestions: triggerSuggestions,
                onToggleSuggestion: (String value) =>
                    draftControllers.toggleSuggestion(
                  draftControllers.triggers,
                  value,
                ),
              ),
              const SizedBox(height: 18),
              PersonalPlanListField(
                title: 'Danger windows',
                helper:
                    'Times or situations when extra protection helps.',
                controller: draftControllers.dangerWindows,
                suggestions: dangerWindowSuggestions,
                onToggleSuggestion: (String value) =>
                    draftControllers.toggleSuggestion(
                  draftControllers.dangerWindows,
                  value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PersonalPlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const PersonalPlanSectionTitle('My first moves'),
              const SizedBox(height: 10),
              PersonalPlanListField(
                title: 'Redirect actions',
                helper:
                    'Choose actions you can take before momentum builds.',
                controller: draftControllers.redirectActions,
                suggestions: redirectSuggestions,
                onToggleSuggestion: (String value) =>
                    draftControllers.toggleSuggestion(
                  draftControllers.redirectActions,
                  value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PersonalPlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const PersonalPlanSectionTitle(
                'Support and boundaries',
              ),
              const SizedBox(height: 10),
              TextField(
                controller: draftControllers.trustedSupport,
                decoration: const InputDecoration(
                  labelText: 'Trusted support person',
                  hintText: 'Name only',
                  helperText:
                      'Calling and messaging details remain in Support.',
                ),
                textCapitalization:
                    TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: draftControllers.phoneBoundary,
                decoration: const InputDecoration(
                  labelText: 'Phone or environment boundary',
                  hintText:
                      'Example: Charge my phone outside the bedroom.',
                ),
                minLines: 2,
                maxLines: 4,
                textCapitalization:
                    TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: draftControllers.bedtimeStrategy,
                decoration: const InputDecoration(
                  labelText: 'Bedtime strategy',
                  hintText:
                      'Example: Phone away, lights out, read for ten minutes.',
                ),
                minLines: 2,
                maxLines: 4,
                textCapitalization:
                    TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PersonalPlanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const PersonalPlanSectionTitle('After a slip'),
              const SizedBox(height: 10),
              const Text(
                'Write the next honest steps—not a punishment.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: draftControllers.afterSlipReset,
                decoration: const InputDecoration(
                  labelText: 'My reset plan',
                  hintText:
                      'Example: Stop, tell the truth, log what happened, and restart.',
                ),
                minLines: 3,
                maxLines: 6,
                textCapitalization:
                    TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        if (mode == RecoveryMode.christian) ...<Widget>[
          const SizedBox(height: 16),
          PersonalPlanCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const PersonalPlanSectionTitle('Faith support'),
                const SizedBox(height: 10),
                const Text(
                  'Add prayer, Scripture, or a faithful next '
                  'step you want available when the wave rises.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: draftControllers.faithSupport,
                  decoration: const InputDecoration(
                    labelText: 'My faith-based support plan',
                    hintText:
                        'Example: Pray honestly, read my saved verse, and contact support.',
                  ),
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization:
                      TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ],
        if (statusMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          PersonalPlanCard(
            child: Text(
              statusMessage!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed:
                saving || (!dirty && hasSavedPlan)
                    ? null
                    : onSave,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Text(
                saving
                    ? 'Saving...'
                    : (!dirty && hasSavedPlan)
                        ? 'Plan saved'
                        : 'Save recovery plan',
              ),
            ),
          ),
        ),
      ],
    );
  }

}
