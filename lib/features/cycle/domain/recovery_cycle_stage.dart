// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_cycle_stage.dart
// Purpose: BW-27 recovery cycle stage model.
// Notes: Teachable five-stage cycle for BreakWave.
// ------------------------------------------------------------

class RecoveryCycleStage {
  const RecoveryCycleStage({
    required this.id,
    required this.title,
    required this.summary,
    required this.pattern,
    required this.interruptMove,
  });

  final String id;
  final String title;
  final String summary;
  final String pattern;
  final String interruptMove;
}

class RecoveryCycleStages {
  static const List<RecoveryCycleStage> all = <RecoveryCycleStage>[
    RecoveryCycleStage(
      id: 'trigger',
      title: 'Trigger',
      summary: 'Something starts the wave.',
      pattern: 'This might be stress, boredom, loneliness, scrolling, late-night drift, or conflict.',
      interruptMove: 'Name the trigger early instead of pretending nothing started.',
    ),
    RecoveryCycleStage(
      id: 'urge',
      title: 'Urge',
      summary: 'The pull becomes noticeable.',
      pattern: 'Your body and attention begin leaning toward the old pattern, even before you act.',
      interruptMove: 'Open Rescue or log the wave before the urge starts bargaining with you.',
    ),
    RecoveryCycleStage(
      id: 'escalation',
      title: 'Escalation',
      summary: 'The wave gets louder and more persuasive.',
      pattern: 'You start drifting toward secrecy, rationalizing, isolating, or staying too close to the setup.',
      interruptMove: 'Change rooms, change posture, and make the setup less private immediately.',
    ),
    RecoveryCycleStage(
      id: 'action',
      title: 'Action',
      summary: 'The pattern gets acted out.',
      pattern: 'This is the point where the habit takes over if nothing interrupts it in time.',
      interruptMove: 'Do not wait for perfect motivation. Break the sequence with one concrete move now.',
    ),
    RecoveryCycleStage(
      id: 'recovery',
      title: 'Regret / Recovery',
      summary: 'The moment after matters too.',
      pattern: 'Shame can try to push you deeper into hiding, or honesty can start rebuilding control.',
      interruptMove: 'Return to truth quickly: log honestly, use support, and take the next clean step.',
    ),
  ];
}
