// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: christian_rescue_card_pack.dart
// Purpose: BW-17 Christian rescue card pack v1.
// Notes: Explicitly Christian rescue content for Christian mode.
// ------------------------------------------------------------

import 'rescue_card_content.dart';

class ChristianRescueCardPack {
  static const List<RescueCardContent> cards = <RescueCardContent>[
    RescueCardContent(
      id: 'christian-grace-first',
      title: 'Grace first, not panic',
      calmLine: 'You are not abandoned in this moment.',
      reframe: 'An urge is real, but it is not bigger than God\'s mercy or your next faithful step.',
      immediateAction: 'Take one slow breath and pray: Lord, help me obey You in the next minute.',
      nextStep: 'Move away from the trigger and choose one concrete act of obedience right now.',
    ),
    RescueCardContent(
      id: 'christian-light-shift',
      title: 'Step into the light',
      calmLine: 'Secrecy makes the wave feel stronger than it is.',
      reframe: 'Bringing this moment into honesty weakens the habit loop and strengthens your integrity.',
      immediateAction: 'Say plainly before God: this is temptation, and I do not want to feed it.',
      nextStep: 'Change rooms, change posture, and stay where it is harder to hide.',
    ),
    RescueCardContent(
      id: 'christian-body-and-mind',
      title: 'Interrupt the pattern',
      calmLine: 'Faithful action can begin before your feelings calm down.',
      reframe: 'You do not need perfect peace before obedience. You just need the next right move.',
      immediateAction: 'Put the phone down, stand up, and take ten slow steps while asking God for strength.',
      nextStep: 'After that, choose Rescue again, message support, or move into a safer environment.',
    ),
  ];
}
