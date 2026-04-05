// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: secular_rescue_card_pack.dart
// Purpose: BW-18 secular rescue card pack v1.
// Notes: Explicitly secular rescue content for secular mode.
// ------------------------------------------------------------

import 'rescue_card_content.dart';

class SecularRescueCardPack {
  static const List<RescueCardContent> cards = <RescueCardContent>[
    RescueCardContent(
      id: 'secular-slow-first-minute',
      title: 'Slow the first minute',
      calmLine: 'You do not need to solve the whole night right now.',
      reframe: 'An urge can feel urgent without being something you have to obey.',
      immediateAction: 'Take one slow breath, loosen your shoulders, and put a little space between you and the trigger.',
      nextStep: 'Then choose one small action that makes the next ten minutes safer.',
    ),
    RescueCardContent(
      id: 'secular-change-the-setup',
      title: 'Change the setup',
      calmLine: 'A physical shift can weaken a mental loop.',
      reframe: 'Staying in the same room, same posture, and same scroll pattern makes the habit easier to follow.',
      immediateAction: 'Stand up, move to a brighter space, and make the current setup less private.',
      nextStep: 'Once you move, decide whether you need water, a walk, or a different environment.',
    ),
    RescueCardContent(
      id: 'secular-name-the-wave',
      title: 'Name the wave clearly',
      calmLine: 'Clear language lowers blur.',
      reframe: 'When you name what is happening plainly, you get a little distance from it.',
      immediateAction: 'Say to yourself: this is an urge, not a decision yet.',
      nextStep: 'Then choose the next good move before the habit starts bargaining with you.',
    ),
  ];
}
