// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: rescue_outcome_reconciler.dart
// Purpose: IOS-G2H best-effort post-auth reconciliation into normal Log history.
// ------------------------------------------------------------

import '../../log/data/log_repository.dart';
import '../../log/domain/log_entry.dart';
import '../domain/pending_rescue_outcome.dart';
import 'rescue_safe_outcome_store.dart';

class RescueOutcomeReconciliationResult {
  const RescueOutcomeReconciliationResult({required this.discovered, required this.reconciled, required this.alreadyPresent, required this.failed});
  final int discovered;
  final int reconciled;
  final int alreadyPresent;
  final int failed;
}

class RescueOutcomeReconciler {
  const RescueOutcomeReconciler({this.pendingStore = const RescueSafeOutcomeStore(), this.logRepository = const LogRepository()});
  final RescueSafeOutcomeStore pendingStore;
  final LogRepository logRepository;

  Future<RescueOutcomeReconciliationResult> reconcile() async {
    List<PendingRescueOutcome> pending;
    try { pending = await pendingStore.loadPending(); } catch (_) {
      return const RescueOutcomeReconciliationResult(discovered: 0, reconciled: 0, alreadyPresent: 0, failed: 1);
    }
    if (pending.isEmpty) return const RescueOutcomeReconciliationResult(discovered: 0, reconciled: 0, alreadyPresent: 0, failed: 0);
    List<LogEntry> existing;
    try { existing = await logRepository.loadEntries(); } catch (_) {
      return RescueOutcomeReconciliationResult(discovered: pending.length, reconciled: 0, alreadyPresent: 0, failed: pending.length);
    }
    final Set<String> existingIds = existing.map((LogEntry e) => e.id).toSet();
    final Set<String> removeIds = <String>{};
    int reconciled = 0, alreadyPresent = 0, failed = 0;
    for (final PendingRescueOutcome outcome in pending) {
      if (existingIds.contains(outcome.id)) { removeIds.add(outcome.id); alreadyPresent += 1; continue; }
      try {
        await logRepository.saveEntry(_toLogEntry(outcome));
        existingIds.add(outcome.id); removeIds.add(outcome.id); reconciled += 1;
      } catch (_) { failed += 1; }
    }
    if (removeIds.isNotEmpty) {
      try { await pendingStore.removeIds(removeIds); } catch (_) {}
    }
    return RescueOutcomeReconciliationResult(discovered: pending.length, reconciled: reconciled, alreadyPresent: alreadyPresent, failed: failed);
  }

  LogEntry _toLogEntry(PendingRescueOutcome outcome) {
    final String trigger = switch (outcome.genericOutcomeTag) {
      'lower_now' => 'Lower Now',
      'still_strong' => 'Still Strong',
      _ => throw StateError('Unsupported Rescue-safe outcome tag.'),
    };
    return LogEntry(id: outcome.id, entryType: outcome.entryType, intensity: outcome.intensity, triggers: <String>[trigger], actionTaken: outcome.genericAction, notes: 'Queued from Rescue-safe and added after unlock.', createdAtIso: outcome.createdAtIso);
  }
}
