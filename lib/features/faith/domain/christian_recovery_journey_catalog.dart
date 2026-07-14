// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: christian_recovery_journey_catalog.dart
// Purpose: BW-87B5A2 complete Christian recovery journeys.
// Notes: Uses Scripture references with original BreakWave
// summaries rather than lengthy quotations from translations.
// ------------------------------------------------------------

import 'christian_recovery_journey.dart';

class ChristianRecoveryJourneyCatalog {
  static const String contentNote =
      'Scripture references guide you to the passage. '
      'BreakWave provides original recovery-focused context, '
      'not a replacement for pastoral, medical, or professional care.';

  static const List<ChristianRecoveryJourney> journeys =
      <ChristianRecoveryJourney>[
    ChristianRecoveryJourney(
      id: 'grace-after-a-slip',
      title: 'Grace after a slip',
      summary:
          'Return to truth without letting shame turn one fall into a longer retreat.',
      whenToUse:
          'after a slip, or when condemnation is pushing you toward hiding.',
      estimatedMinutes: 9,
      steps: <ChristianJourneyStep>[
        ChristianJourneyStep(
          id: 'grace-scripture',
          kind: ChristianJourneyStepKind.scripture,
          title: 'Begin with grace',
          scriptureReference: 'Romans 8:1',
          body:
              'Read the passage slowly. Notice that life in Christ moves you away from condemnation and toward honest return.',
        ),
        ChristianJourneyStep(
          id: 'grace-context',
          kind: ChristianJourneyStepKind.context,
          title: 'Grace makes honesty possible',
          body:
              'Grace does not pretend the slip did not matter. It gives you room to tell the truth, learn, repair, and take the next faithful step.',
        ),
        ChristianJourneyStep(
          id: 'grace-reflection',
          kind: ChristianJourneyStepKind.reflection,
          title: 'Name the spiral',
          body:
              'What is shame asking you to do next: hide, give up, minimize, or continue? Name that pressure without agreeing with it.',
        ),
        ChristianJourneyStep(
          id: 'grace-action',
          kind: ChristianJourneyStepKind.action,
          title: 'Restore one boundary',
          body:
              'Open your recovery plan and strengthen one boundary connected to what happened. One honest repair is enough for this moment.',
          actionTarget:
              ChristianJourneyActionTarget.personalPlan,
          actionLabel: 'Open personal recovery plan',
        ),
        ChristianJourneyStep(
          id: 'grace-prayer',
          kind: ChristianJourneyStepKind.prayer,
          title: 'Pray honestly',
          body:
              'Lord, I am returning without excuses and without despair. Help me receive grace, tell the truth, and take one faithful repair step.',
        ),
      ],
    ),
    ChristianRecoveryJourney(
      id: 'renew-the-next-thought',
      title: 'Renew the next thought',
      summary:
          'Interrupt a thought pattern before it gathers momentum and becomes a decision.',
      whenToUse:
          'fantasy, bargaining, or repetitive thoughts begin pulling your attention.',
      estimatedMinutes: 8,
      steps: <ChristianJourneyStep>[
        ChristianJourneyStep(
          id: 'renew-scripture',
          kind: ChristianJourneyStepKind.scripture,
          title: 'Turn toward renewal',
          scriptureReference: 'Romans 12:2',
          body:
              'Read the passage and notice that transformation includes learning a different pattern of thought and response.',
        ),
        ChristianJourneyStep(
          id: 'renew-context',
          kind: ChristianJourneyStepKind.context,
          title: 'A thought is not an instruction',
          body:
              'An unwanted thought can be present without becoming your plan. Renewal begins when you stop treating every thought as something you must follow.',
        ),
        ChristianJourneyStep(
          id: 'renew-reflection',
          kind: ChristianJourneyStepKind.reflection,
          title: 'Identify the bargain',
          body:
              'What promise is the thought making right now—relief, escape, comfort, control, or numbness? What usually comes afterward?',
        ),
        ChristianJourneyStep(
          id: 'renew-action',
          kind: ChristianJourneyStepKind.action,
          title: 'Interrupt the pattern',
          body:
              'Open Rescue and choose a physical interruption before continuing to reason with the urge.',
          actionTarget:
              ChristianJourneyActionTarget.rescue,
          actionLabel: 'Open Rescue',
        ),
        ChristianJourneyStep(
          id: 'renew-prayer',
          kind: ChristianJourneyStepKind.prayer,
          title: 'Ask for a steadier mind',
          body:
              'God, help me notice this thought without surrendering to it. Renew my attention and guide my next decision toward life.',
        ),
      ],
    ),
    ChristianRecoveryJourney(
      id: 'step-into-the-light',
      title: 'Step into the light',
      summary:
          'Reduce secrecy through truth, safer surroundings, and prepared support.',
      whenToUse:
          'isolation or secrecy makes the habit feel easier to protect.',
      estimatedMinutes: 10,
      steps: <ChristianJourneyStep>[
        ChristianJourneyStep(
          id: 'light-scripture',
          kind: ChristianJourneyStepKind.scripture,
          title: 'Choose honest connection',
          scriptureReference: 'James 5:16',
          body:
              'Read the passage and notice the connection between honest confession, prayer, and healing community.',
        ),
        ChristianJourneyStep(
          id: 'light-context',
          kind: ChristianJourneyStepKind.context,
          title: 'Secrecy strengthens the loop',
          body:
              'Recovery does not require public disclosure to everyone. It does require moving away from total isolation and toward safe, appropriate honesty.',
        ),
        ChristianJourneyStep(
          id: 'light-reflection',
          kind: ChristianJourneyStepKind.reflection,
          title: 'Notice where hiding begins',
          body:
              'Which setup makes secrecy easiest for you: a room, device, time, account, or habit? Identify the earliest point where you can change direction.',
        ),
        ChristianJourneyStep(
          id: 'light-action',
          kind: ChristianJourneyStepKind.action,
          title: 'Prepare support before urgency',
          body:
              'Open your recovery plan and confirm who you can contact and what environment makes secrecy harder.',
          actionTarget:
              ChristianJourneyActionTarget.personalPlan,
          actionLabel: 'Open personal recovery plan',
        ),
        ChristianJourneyStep(
          id: 'light-prayer',
          kind: ChristianJourneyStepKind.prayer,
          title: 'Pray for courage',
          body:
              'Lord, give me wisdom about what to share, courage to leave hiding, and humility to receive safe support.',
        ),
      ],
    ),
    ChristianRecoveryJourney(
      id: 'answer-loneliness-with-presence',
      title: 'Answer loneliness with presence',
      summary:
          'Respond to loneliness as a real need without turning toward false comfort.',
      whenToUse:
          'you feel lonely, rejected, bored, or disconnected.',
      estimatedMinutes: 9,
      steps: <ChristianJourneyStep>[
        ChristianJourneyStep(
          id: 'presence-scripture',
          kind: ChristianJourneyStepKind.scripture,
          title: 'God is near to the hurting',
          scriptureReference: 'Psalm 34:18',
          body:
              'Read the passage and allow loneliness to be named as pain rather than treated as permission to return to a harmful pattern.',
        ),
        ChristianJourneyStep(
          id: 'presence-context',
          kind: ChristianJourneyStepKind.context,
          title: 'The ache deserves a real answer',
          body:
              'Pornography may briefly distract from loneliness, but it cannot provide mutual presence, belonging, or lasting care.',
        ),
        ChristianJourneyStep(
          id: 'presence-reflection',
          kind: ChristianJourneyStepKind.reflection,
          title: 'Name what you are missing',
          body:
              'Are you needing conversation, reassurance, rest, affection, community, or simply another person nearby? Be specific without judging the need.',
        ),
        ChristianJourneyStep(
          id: 'presence-action',
          kind: ChristianJourneyStepKind.action,
          title: 'Move toward safer presence',
          body:
              'Use Rescue to change your environment, regulate the immediate wave, and choose one reconnecting action.',
          actionTarget:
              ChristianJourneyActionTarget.rescue,
          actionLabel: 'Open Rescue',
        ),
        ChristianJourneyStep(
          id: 'presence-prayer',
          kind: ChristianJourneyStepKind.prayer,
          title: 'Bring the ache to God',
          body:
              'Father, meet me in this loneliness. Help me seek real connection and refuse the substitute that leaves me more isolated afterward.',
        ),
      ],
    ),
    ChristianRecoveryJourney(
      id: 'practice-small-integrity',
      title: 'Practice small integrity',
      summary:
          'Build integrity through repeatable choices rather than dramatic promises.',
      whenToUse:
          'you feel pressure to fix everything at once or prove yourself through perfection.',
      estimatedMinutes: 8,
      steps: <ChristianJourneyStep>[
        ChristianJourneyStep(
          id: 'integrity-scripture',
          kind: ChristianJourneyStepKind.scripture,
          title: 'Faithfulness begins small',
          scriptureReference: 'Luke 16:10',
          body:
              'Read the passage and notice the value placed on faithfulness in small responsibilities and decisions.',
        ),
        ChristianJourneyStep(
          id: 'integrity-context',
          kind: ChristianJourneyStepKind.context,
          title: 'Recovery is built repeatedly',
          body:
              'Integrity usually grows through ordinary boundaries kept many times—not through one emotional promise that removes every future struggle.',
        ),
        ChristianJourneyStep(
          id: 'integrity-reflection',
          kind: ChristianJourneyStepKind.reflection,
          title: 'Choose today’s responsibility',
          body:
              'Which single boundary would make the greatest difference during the next twenty-four hours?',
        ),
        ChristianJourneyStep(
          id: 'integrity-action',
          kind: ChristianJourneyStepKind.action,
          title: 'Write the boundary clearly',
          body:
              'Open your recovery plan and turn that boundary into a specific action you can recognize and repeat.',
          actionTarget:
              ChristianJourneyActionTarget.personalPlan,
          actionLabel: 'Open personal recovery plan',
        ),
        ChristianJourneyStep(
          id: 'integrity-prayer',
          kind: ChristianJourneyStepKind.prayer,
          title: 'Ask for steady faithfulness',
          body:
              'God, keep me from chasing perfection or making empty promises. Strengthen me to practice integrity in the next small decision.',
        ),
      ],
    ),
    ChristianRecoveryJourney(
      id: 'guard-the-night',
      title: 'Guard the night',
      summary:
          'Prepare for a vulnerable evening before fatigue and isolation narrow your choices.',
      whenToUse:
          'before bedtime, late-night scrolling, travel, or another predictable risk window.',
      estimatedMinutes: 10,
      steps: <ChristianJourneyStep>[
        ChristianJourneyStep(
          id: 'night-scripture',
          kind: ChristianJourneyStepKind.scripture,
          title: 'Watch and pray',
          scriptureReference: 'Matthew 26:41',
          body:
              'Read the passage and notice that spiritual intention and human vulnerability are both taken seriously.',
        ),
        ChristianJourneyStep(
          id: 'night-context',
          kind: ChristianJourneyStepKind.context,
          title: 'Preparation is not fear',
          body:
              'Recognizing a risky time is wisdom. A bedtime boundary can protect tomorrow’s values before exhaustion weakens today’s judgment.',
        ),
        ChristianJourneyStep(
          id: 'night-reflection',
          kind: ChristianJourneyStepKind.reflection,
          title: 'Identify tonight’s opening',
          body:
              'What combination creates the most risk tonight: fatigue, privacy, unrestricted browsing, stress, or staying awake without purpose?',
        ),
        ChristianJourneyStep(
          id: 'night-action',
          kind: ChristianJourneyStepKind.action,
          title: 'Create distance now',
          body:
              'Open Rescue and complete one immediate environment change before the vulnerable window deepens.',
          actionTarget:
              ChristianJourneyActionTarget.rescue,
          actionLabel: 'Open Rescue',
        ),
        ChristianJourneyStep(
          id: 'night-prayer',
          kind: ChristianJourneyStepKind.prayer,
          title: 'Commit the night',
          body:
              'Lord, help me prepare wisely rather than depend on tired willpower. Guard my attention and lead me toward rest, honesty, and peace.',
        ),
      ],
    ),
  ];

  static ChristianRecoveryJourney? findById(
    String journeyId,
  ) {
    for (final ChristianRecoveryJourney journey
        in journeys) {
      if (journey.id == journeyId) {
        return journey;
      }
    }

    return null;
  }
}
