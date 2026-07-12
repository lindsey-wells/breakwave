// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_routine_catalog.dart
// Purpose: Six practical guided recovery routines.
// Notes: BW-87B4A adapts wording to the selected recovery mode.
// Notes: Routines lead to real actions rather than passive reading.
// ------------------------------------------------------------

import '../../../core/recovery/recovery_mode.dart';
import 'recovery_routine.dart';

class RecoveryRoutineCatalog {
  const RecoveryRoutineCatalog._();

  static List<RecoveryRoutine> forMode(
    RecoveryMode mode,
  ) {
    return List<RecoveryRoutine>.unmodifiable(
      <RecoveryRoutine>[
        _morningReset(mode),
        _stressInterruption(mode),
        _lonelinessResponse(mode),
        _phoneBoundaryReset(mode),
        _bedtimeProtection(mode),
        _afterSlipReset(mode),
      ],
    );
  }

  static RecoveryRoutine? findById(
    String id,
    RecoveryMode mode,
  ) {
    for (final RecoveryRoutine routine in forMode(mode)) {
      if (routine.id == id) {
        return routine;
      }
    }

    return null;
  }

  static RecoveryRoutine _morningReset(
    RecoveryMode mode,
  ) {
    return RecoveryRoutine(
      id: 'morning-reset',
      title: 'Morning reset',
      summary:
          'Begin the day with one clear reason, one boundary, and one plan for the riskiest moment.',
      whenToUse:
          'Use after waking up or before the day begins pulling your attention in different directions.',
      estimatedMinutes: 4,
      steps: <RecoveryRoutineStep>[
        _step(
          mode: mode,
          id: 'morning-present',
          title: 'Get physically present',
          secular:
              'Put both feet on the floor. Take three slow breaths and notice what your body is carrying into the day.',
          christian:
              'Put both feet on the floor. Take three slow breaths and ask God for honesty, steadiness, and strength for today.',
        ),
        _step(
          mode: mode,
          id: 'morning-reason',
          title: 'Name today’s reason',
          secular:
              'Read or say the reason that matters most today. Keep it specific enough to guide one real choice.',
          christian:
              'Read or say the reason that matters most today. Offer that reason to God and connect it to one faithful choice.',
          actionTarget:
              RoutineActionTarget.personalPlan,
          actionLabel: 'Open personal recovery plan',
        ),
        _step(
          mode: mode,
          id: 'morning-boundary',
          title: 'Choose one boundary',
          secular:
              'Choose one phone or environment boundary you will keep today. Make it practical and observable.',
          christian:
              'Choose one phone or environment boundary you will keep today as a concrete act of wisdom and integrity.',
        ),
        _step(
          mode: mode,
          id: 'morning-risk-window',
          title: 'Plan for the riskiest window',
          secular:
              'Name the time or situation most likely to become difficult and decide your first interruption move now.',
          christian:
              'Name the time or situation most likely to become difficult and decide your first faithful interruption move now.',
        ),
      ],
    );
  }

  static RecoveryRoutine _stressInterruption(
    RecoveryMode mode,
  ) {
    return RecoveryRoutine(
      id: 'stress-interruption',
      title: 'Stress interruption',
      summary:
          'Lower physical pressure, create distance from the trigger, and choose the next right action.',
      whenToUse:
          'Use when stress, anger, pressure, or mental overload starts pushing you toward the old pattern.',
      estimatedMinutes: 6,
      steps: <RecoveryRoutineStep>[
        _step(
          mode: mode,
          id: 'stress-name',
          title: 'Name the pressure',
          secular:
              'Say what is stressing you in one plain sentence. Do not solve everything yet—name what is happening.',
          christian:
              'Say honestly what is stressing you in one plain sentence. Bring the pressure into the light instead of hiding it.',
        ),
        _step(
          mode: mode,
          id: 'stress-body',
          title: 'Interrupt the body',
          secular:
              'Stand up, loosen your hands and jaw, and breathe out slowly three times. Let your body receive the interruption.',
          christian:
              'Stand up, loosen your hands and jaw, and breathe out slowly three times while asking God to steady your next action.',
        ),
        _step(
          mode: mode,
          id: 'stress-distance',
          title: 'Create distance',
          secular:
              'Move away from the screen, room, or situation feeding the urge. Distance is an action, not a failure.',
          christian:
              'Move away from the screen, room, or situation feeding the urge. Leaving the trap is a wise and faithful action.',
          actionTarget: RoutineActionTarget.rescue,
          actionLabel: 'Open Rescue',
        ),
        _step(
          mode: mode,
          id: 'stress-next-action',
          title: 'Choose the next right action',
          secular:
              'Choose one small action that reduces pressure without feeding the compulsive pattern.',
          christian:
              'Choose one small faithful action that reduces pressure without feeding the compulsive pattern.',
        ),
        _step(
          mode: mode,
          id: 'stress-record',
          title: 'Record what helped',
          secular:
              'After the pressure drops, record what triggered the wave and what helped interrupt it.',
          christian:
              'After the pressure drops, record what triggered the wave and what helped you respond with honesty.',
          actionTarget: RoutineActionTarget.log,
          actionLabel: 'Open Log',
        ),
      ],
    );
  }

  static RecoveryRoutine _lonelinessResponse(
    RecoveryMode mode,
  ) {
    return RecoveryRoutine(
      id: 'loneliness-response',
      title: 'Loneliness response',
      summary:
          'Answer isolation with movement, safe connection, and one grounded action.',
      whenToUse:
          'Use when loneliness, rejection, secrecy, or isolation begins increasing temptation.',
      estimatedMinutes: 7,
      steps: <RecoveryRoutineStep>[
        _step(
          mode: mode,
          id: 'lonely-leave-isolation',
          title: 'Leave isolation',
          secular:
              'Move to a brighter, shared, or more public space. Change the environment before debating the urge.',
          christian:
              'Move to a brighter, shared, or more public space. Choose light and honest presence before debating the urge.',
        ),
        _step(
          mode: mode,
          id: 'lonely-contact',
          title: 'Contact one safe person',
          secular:
              'Send one honest message or make one call. You do not need a perfect explanation—start contact.',
          christian:
              'Send one honest message or make one call. Recovery is not meant to be carried alone.',
          actionTarget: RoutineActionTarget.support,
          actionLabel: 'Open Support',
        ),
        _step(
          mode: mode,
          id: 'lonely-physical-action',
          title: 'Do one embodied task',
          secular:
              'Walk, shower, prepare food, clean one surface, or do another physical task that reconnects you with the present.',
          christian:
              'Walk, shower, prepare food, clean one surface, or do another physical task with gratitude for the life in front of you.',
        ),
        _step(
          mode: mode,
          id: 'lonely-return-reason',
          title: 'Return to your reason',
          secular:
              'Read your main recovery reason and choose one action that protects it tonight.',
          christian:
              'Read your main recovery reason and choose one faithful action that protects it tonight.',
          actionTarget:
              RoutineActionTarget.personalPlan,
          actionLabel: 'Open personal recovery plan',
        ),
      ],
    );
  }

  static RecoveryRoutine _phoneBoundaryReset(
    RecoveryMode mode,
  ) {
    return RecoveryRoutine(
      id: 'phone-boundary-reset',
      title: 'Phone-boundary reset',
      summary:
          'Create physical distance from the device and restore a boundary that can survive the next urge.',
      whenToUse:
          'Use after risky scrolling, private browsing, boundary drift, or taking the phone somewhere it should not be.',
      estimatedMinutes: 5,
      steps: <RecoveryRoutineStep>[
        _step(
          mode: mode,
          id: 'phone-put-down',
          title: 'Put the phone down',
          secular:
              'Set the phone on a stable surface and remove your hands from it for sixty seconds.',
          christian:
              'Set the phone on a stable surface and remove your hands from it for sixty seconds. Let the pause become an honest choice.',
        ),
        _step(
          mode: mode,
          id: 'phone-out-of-reach',
          title: 'Move it out of reach',
          secular:
              'Place the phone across the room, outside the bedroom, or with another person.',
          christian:
              'Place the phone across the room, outside the bedroom, or with another person. Choose wisdom over easy access.',
        ),
        _step(
          mode: mode,
          id: 'phone-close-route',
          title: 'Close the private route',
          secular:
              'Leave the private space, close the risky app or browser, and move toward a visible activity.',
          christian:
              'Leave the private space, close the risky app or browser, and move toward openness instead of secrecy.',
        ),
        _step(
          mode: mode,
          id: 'phone-save-boundary',
          title: 'Strengthen the boundary',
          secular:
              'Write or update the phone boundary that would make this situation harder to repeat.',
          christian:
              'Write or update the phone boundary that supports honesty, wisdom, and integrity.',
          actionTarget:
              RoutineActionTarget.personalPlan,
          actionLabel: 'Open personal recovery plan',
        ),
      ],
    );
  }

  static RecoveryRoutine _bedtimeProtection(
    RecoveryMode mode,
  ) {
    return RecoveryRoutine(
      id: 'bedtime-protection',
      title: 'Bedtime protection',
      summary:
          'Reduce access, lower stimulation, and prepare a clear response before the late-night wave begins.',
      whenToUse:
          'Use before bed, especially when tiredness, privacy, or late-night phone use increases risk.',
      estimatedMinutes: 6,
      steps: <RecoveryRoutineStep>[
        _step(
          mode: mode,
          id: 'bedtime-end-scroll',
          title: 'End the scrolling window',
          secular:
              'Choose a stopping point now. Close entertainment and social apps instead of waiting until self-control is exhausted.',
          christian:
              'Choose a stopping point now. Close entertainment and social apps as an act of wisdom before exhaustion takes over.',
        ),
        _step(
          mode: mode,
          id: 'bedtime-charge-away',
          title: 'Charge outside reach',
          secular:
              'Move the phone away from the bed or outside the room before lying down.',
          christian:
              'Move the phone away from the bed or outside the room before lying down. Protect the quiet of the night.',
        ),
        _step(
          mode: mode,
          id: 'bedtime-lower-stimulation',
          title: 'Lower stimulation',
          secular:
              'Dim the room, drink water, read, stretch, or choose another calm activity that does not require private browsing.',
          christian:
              'Dim the room, drink water, read, stretch, pray, or choose another calm activity that does not feed secrecy.',
        ),
        _step(
          mode: mode,
          id: 'bedtime-rescue-plan',
          title: 'Prepare the emergency move',
          secular:
              'Decide now: if the wave rises, stand up immediately and open Rescue before negotiating with it.',
          christian:
              'Decide now: if the wave rises, stand up immediately, pray honestly, and open Rescue before negotiating with it.',
          actionTarget: RoutineActionTarget.rescue,
          actionLabel: 'Open Rescue',
        ),
        _step(
          mode: mode,
          id: 'bedtime-close-day',
          title: 'Close the day without shame',
          secular:
              'A difficult day does not require a destructive ending. Choose rest and begin again tomorrow.',
          christian:
              'A difficult day does not place you beyond grace. Choose honesty, rest, and a faithful beginning tomorrow.',
        ),
      ],
    );
  }

  static RecoveryRoutine _afterSlipReset(
    RecoveryMode mode,
  ) {
    return RecoveryRoutine(
      id: 'after-slip-reset',
      title: 'Getting back on track',
      summary:
          'Stop the shame spiral, record what happened, restore support, and change one condition before restarting.',
      whenToUse:
          'Use after a slip or when one difficult moment is starting to become a longer return to the old pattern.',
      estimatedMinutes: 8,
      steps: <RecoveryRoutineStep>[
        _step(
          mode: mode,
          id: 'slip-stop-spiral',
          title: 'Stop the spiral',
          secular:
              'Pause. One slip does not require another. Put down the device and take one slow breath before deciding what comes next.',
          christian:
              'Pause. One slip does not require another. Grace invites honesty and the next faithful step—not hiding or surrender.',
        ),
        _step(
          mode: mode,
          id: 'slip-record-facts',
          title: 'Record facts, not insults',
          secular:
              'Record what happened, what triggered it, and what action came before it. Avoid attacking your identity.',
          christian:
              'Record what happened, what triggered it, and what action came before it. Tell the truth without turning shame into your identity.',
          actionTarget: RoutineActionTarget.log,
          actionLabel: 'Open Log',
        ),
        _step(
          mode: mode,
          id: 'slip-contact-support',
          title: 'Tell the truth to someone safe',
          secular:
              'Contact your trusted person or another safe support. A short honest message is enough to break secrecy.',
          christian:
              'Contact your trusted person or another safe support. Bringing the moment into the light makes secrecy weaker.',
          actionTarget: RoutineActionTarget.support,
          actionLabel: 'Open Support',
        ),
        _step(
          mode: mode,
          id: 'slip-change-condition',
          title: 'Change one condition',
          secular:
              'Change one part of the environment that made the slip easier: location, device access, privacy, fatigue, or isolation.',
          christian:
              'Change one part of the environment that made the slip easier. Repentance includes a practical change of direction.',
        ),
        _step(
          mode: mode,
          id: 'slip-restart-plan',
          title: 'Restart the plan',
          secular:
              'Review your recovery plan and choose the first boundary or redirect action you will restore today.',
          christian:
              'Review your recovery plan and choose the first faithful boundary or redirect action you will restore today.',
          actionTarget:
              RoutineActionTarget.personalPlan,
          actionLabel: 'Open personal recovery plan',
        ),
      ],
    );
  }

  static RecoveryRoutineStep _step({
    required RecoveryMode mode,
    required String id,
    required String title,
    required String secular,
    required String christian,
    RoutineActionTarget? actionTarget,
    String actionLabel = '',
  }) {
    return RecoveryRoutineStep(
      id: id,
      title: title,
      instruction: mode == RecoveryMode.christian
          ? christian
          : secular,
      actionTarget: actionTarget,
      actionLabel: actionLabel,
    );
  }
}
