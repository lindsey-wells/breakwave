// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_card_pack.dart
// Purpose: BW-16 starter rescue card pack.
// Notes: Neutral starter pack before Christian/secular branching.
// ------------------------------------------------------------

import 'rescue_card_content.dart';

class RescueCardPack {
  static const List<RescueCardContent> starter = <RescueCardContent>[
    RescueCardContent(
      id: 'slow-down',
      title: 'Slow the first minute',
      calmLine: 'You do not need to solve the whole night right now.',
      reframe: 'A wave feels urgent, but urgency is not the same as command.',
      immediateAction: 'Put the phone down for 60 seconds and breathe out longer than you breathe in.',
      nextStep: 'When the body softens even a little, choose one safer next move.',
    ),
    RescueCardContent(
      id: 'change-the-room',
      title: 'Change the environment',
      calmLine: 'A small physical shift can interrupt a strong mental loop.',
      reframe: 'Staying in the exact same setup makes the habit easier to obey.',
      immediateAction: 'Stand up, move to a brighter room, and put distance between you and the trigger.',
      nextStep: 'Once you move, decide whether you need water, a walk, or support.',
    ),
    RescueCardContent(
      id: 'name-it-plainly',
      title: 'Name what is happening',
      calmLine: 'Clarity lowers blur.',
      reframe: 'When you name the wave honestly, it becomes more workable and less foggy.',
      immediateAction: 'Say to yourself: this is an urge, not a decision yet.',
      nextStep: 'Then choose the next good action before negotiating with the habit.',
    ),
  ];
}
