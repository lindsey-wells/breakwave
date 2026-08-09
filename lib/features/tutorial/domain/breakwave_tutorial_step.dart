// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_tutorial_step.dart
// Purpose: Mode-aware, access-policy-backed tutorial content.
// Notes: BW-ONBOARD-01B1 explains Free and Plus without guessing.
// ------------------------------------------------------------

import '../../../core/access/breakwave_access_policy.dart';
import '../../../core/access/breakwave_feature.dart';
import '../../../core/recovery/recovery_mode.dart';

enum BreakWaveTutorialTopic {
  overview,
  rescue,
  home,
  log,
  recoveryTools,
  privacyAndAccess,
}

class BreakWaveTutorialStep {
  const BreakWaveTutorialStep({
    required this.topic,
    required this.title,
    required this.summary,
    required this.points,
  });

  final BreakWaveTutorialTopic topic;
  final String title;
  final String summary;
  final List<String> points;
}

class BreakWaveTutorialCatalog {
  const BreakWaveTutorialCatalog._();

  static List<BreakWaveTutorialStep> build(RecoveryMode mode) {
    _requireFree(BreakWaveFeature.onboarding);
    _requireFree(BreakWaveFeature.rescueNow);
    _requireFree(BreakWaveFeature.basicLogging);
    _requireFree(BreakWaveFeature.privacySettings);

    final String modePoint = mode == RecoveryMode.christian
        ? 'Your selected Christian mode can use prayer, Scripture, grace, and practical recovery language.'
        : 'Your selected secular mode keeps the guidance practical and free from religious language.';

    final List<BreakWaveFeature> freeFeatures = <BreakWaveFeature>[
      BreakWaveFeature.rescueNow,
      BreakWaveFeature.basicLogging,
      BreakWaveFeature.privacySettings,
      BreakWaveFeature.humanSupportActions,
    ].where(_isFree).toList(growable: false);

    final List<BreakWaveFeature> plusFeatures = <BreakWaveFeature>[
      BreakWaveFeature.advancedRecoveryInsights,
      BreakWaveFeature.savedPersonalRecoveryPlan,
      BreakWaveFeature.guidedRoutines,
      BreakWaveFeature.enhancedRecoveryReports,
      if (mode == RecoveryMode.christian)
        BreakWaveFeature.christianJourneys,
      if (mode == RecoveryMode.christian)
        BreakWaveFeature.extendedChristianDepth,
    ].where(_requiresPlus).toList(growable: false);

    return <BreakWaveTutorialStep>[
      BreakWaveTutorialStep(
        topic: BreakWaveTutorialTopic.overview,
        title: 'What BreakWave is for',
        summary:
            'BreakWave helps you change what happens when an urge appears.',
        points: <String>[
          'Recognize → Interrupt → Redirect → Reinforce is the recovery model that connects the tools you already use.',
          'Notice it → Break it → Choose differently → Strengthen what works is the same idea in everyday language.',
          'Your recovery setup is local-first, and no account is required to use the core app.',
          modePoint,
          'BreakWave is a recovery support tool, not therapy, medical treatment, a diagnosis, a cure, or an emergency service.',
        ],
      ),
      const BreakWaveTutorialStep(
        topic: BreakWaveTutorialTopic.rescue,
        title: 'Rescue comes first',
        summary:
            'Interrupt the pattern before momentum takes over.',
        points: <String>[
          'Recognize the wave by choosing the urge intensity that best matches the moment.',
          'Bring your Personal Why back into view, then use breathing and reset tools to interrupt the old momentum.',
          'Redirect by choosing one next right action you can take immediately.',
          'A different response is progress worth noticing and repeating.',
          'Rescue remains available regardless of onboarding or Plus status.',
        ],
      ),
      const BreakWaveTutorialStep(
        topic: BreakWaveTutorialTopic.home,
        title: 'Use Home to prepare',
        summary:
            'Home helps you recognize risk earlier and prepare a healthier response before the next difficult moment.',
        points: <String>[
          'Current Focus is the recovery reason shown on Home.',
          'Personal Why is the message or image brought into Rescue. They support different moments.',
          'Use check-ins and risk signals to recognize patterns early, and open Rescue quickly when needed.',
          'Preparing a next right action ahead of time makes redirection easier when the wave arrives.',
        ],
      ),
      const BreakWaveTutorialStep(
        topic: BreakWaveTutorialTopic.log,
        title: 'Learn from your Log',
        summary:
            'The private Log helps you recognize patterns and reinforce what helps without turning recovery into a shame scoreboard.',
        points: <String>[
          'Record an Urge, Slip, Victory, or Reflection.',
          'Urge, Slip, and Victory entries can show intensity. Reflections do not use intensity dots.',
          'Add triggers and notes about what helped, then edit or delete entries when needed.',
          'Over time, notice repeating triggers, risky moments, and responses that seem to help.',
          'A slip can be something to learn from. A Victory can help you remember a response worth repeating.',
        ],
      ),
      BreakWaveTutorialStep(
        topic: BreakWaveTutorialTopic.recoveryTools,
        title: 'Build a recovery system',
        summary:
            'BreakWave connects interruption with redirection, planning, routines, insight, and reinforcement over time.',
        points: <String>[
          'Use reasons, triggers, reminders, trusted contacts, and the starter recovery plan to prepare ahead.',
          'Next Right Actions help you redirect toward a healthier response instead of only trying to stop the old one.',
          'Deeper planning, guided routines, expanded insights, and richer reports are approved Plus candidates.',
          if (mode == RecoveryMode.christian)
            'Christian mode can also include explicitly Christian journeys and deeper faith-based recovery material.',
          'You can change recovery mode later from Support.',
        ],
      ),
      BreakWaveTutorialStep(
        topic: BreakWaveTutorialTopic.privacyAndAccess,
        title: 'Privacy, support, and access',
        summary:
            'You stay in control of what you save, protect, export, or deliberately share.',
        points: <String>[
          'Recovery information stays on this device unless you deliberately export or share it.',
          'Use privacy controls, app lock, reminders, and Support whenever they are useful. No app can promise absolute security or anonymity.',
          'Always free: ${_labels(freeFeatures)}.',
          'Plus candidates: ${_labels(plusFeatures)}. Plus helps support continued maintenance and privacy-focused development.',
        ],
      ),
    ];
  }

  static bool _isFree(BreakWaveFeature feature) {
    return !BreakWaveAccessPolicy.accessClassFor(feature).requiresPlus;
  }

  static bool _requiresPlus(BreakWaveFeature feature) {
    return BreakWaveAccessPolicy.accessClassFor(feature).requiresPlus;
  }

  static void _requireFree(BreakWaveFeature feature) {
    if (!_isFree(feature)) {
      throw StateError('${feature.label} must remain available without Plus.');
    }
  }

  static String _labels(List<BreakWaveFeature> features) {
    return features.map((BreakWaveFeature feature) => feature.label).join(', ');
  }
}
