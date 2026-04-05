// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: learning_card_pack.dart
// Purpose: BW-28 learning card pack v1.
// Notes: Short practical lessons tied to immediate recovery action.
// ------------------------------------------------------------

import 'learning_card_content.dart';

class LearningCardPack {
  static const List<LearningCardContent> starter = <LearningCardContent>[
    LearningCardContent(
      id: 'urge-wave',
      title: 'Urges rise and fall',
      meaning: 'An urge feels permanent when it is loud, but it is usually a wave instead of a fixed state.',
      whyItMatters: 'If you treat the urge like a wave, you are more likely to interrupt it instead of obeying it immediately.',
      nextMove: 'Use Rescue, breathe, and give the wave a short window to weaken before making the next decision.',
    ),
    LearningCardContent(
      id: 'secrecy-loop',
      title: 'Secrecy strengthens loops',
      meaning: 'Private setups, hidden scrolling, and isolation make the habit easier to keep feeding.',
      whyItMatters: 'Secrecy lowers friction, which makes old patterns easier to repeat.',
      nextMove: 'Change rooms, change posture, and make the setup less private as early as possible.',
    ),
    LearningCardContent(
      id: 'environment-shift',
      title: 'Changing environment matters',
      meaning: 'The body often follows the setup you stay in.',
      whyItMatters: 'If you stay in the same place with the same trigger pattern, the urge gets to keep building momentum.',
      nextMove: 'Stand up, move somewhere brighter, and create a small physical break in the pattern.',
    ),
    LearningCardContent(
      id: 'shame-pressure',
      title: 'Shame makes relapse worse',
      meaning: 'Shame often pushes a person deeper into hiding instead of toward recovery.',
      whyItMatters: 'When shame takes over, it becomes harder to log honestly, ask for help, or restart quickly.',
      nextMove: 'Use plain truthful language after a hard moment and take one clean next step instead of spiraling.',
    ),
    LearningCardContent(
      id: 'interrupt-beats-negotiate',
      title: 'Interruption beats negotiation',
      meaning: 'Once the wave starts arguing with you, the pattern usually gets stronger.',
      whyItMatters: 'Early interruption often works better than trying to out-think the urge while staying close to it.',
      nextMove: 'Break the sequence fast: open Rescue, move rooms, or reach for support before the habit bargains with you.',
    ),
  ];
}
