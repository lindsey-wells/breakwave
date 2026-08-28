#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

FILES = {
    "progress": ROOT / "lib/features/faith/domain/christian_journey_progress.dart",
    "player": ROOT / "lib/features/faith/presentation/christian_journey_player_screen.dart",
    "catalog": ROOT / "lib/features/faith/domain/christian_recovery_journey_catalog.dart",
    "progress_test": ROOT / "test/christian_journey_progress_test.dart",
    "catalog_test": ROOT / "test/christian_recovery_journey_catalog_test.dart",
    "journal_test": ROOT / "test/christian_journey_private_journal_test.dart",
    "value_map": ROOT / "launch/breakwave_plus_value_wall.md",
    "b5a2": ROOT / "tools/verify_bw87b5a2.py",
    "b5b2p": ROOT / "tools/verify_bw87b5b2p.py",
    "bw54": ROOT / "tools/verify_bw54.py",
}

PROTECTED_BLOBS = {
    "lib/features/recovery_report/domain/recovery_report_selection.dart": "7577b83ac3b561a53d85df1f7a495fc4a45be14c",
    "lib/features/recovery_report/domain/recovery_report_snapshot.dart": "7dc59e8a6e05d6eca343eada21c9a6b68ec50ae6",
    "lib/features/recovery_report/domain/recovery_report_snapshot_builder.dart": "5ae104883c65af034953d7d1c0c86d93e54bd817",
    "lib/features/recovery_report/domain/recovery_report_formatter.dart": "d081cd67d9526e40f357149653dca984abe75b33",
    "lib/features/recovery_report/data/recovery_report_export_service.dart": "f87a44d5b7d1e8924f23c508ebf89fc1f2ba992a",
    "lib/core/access/breakwave_access_policy.dart": "65a276c022d2d802f306f0980214cee072825a9a",
    "lib/features/premium/presentation/breakwave_plus_screen.dart": "59b5424c86c93dd3b2e4e9788f4bfd9e673329f8",
    "tools/verify_bw89a12d.py": "0cffa967f17a676e2d9123ae3a1667315abb44ac",
}


def fail(msg: str) -> None:
    raise SystemExit(f"FAIL BW-89A12F: {msg}")


def read(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def blob_sha(path: Path) -> str:
    data = path.read_bytes()
    return hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()


for rel, expected in PROTECTED_BLOBS.items():
    path = ROOT / rel
    if not path.is_file():
        fail(f"protected A12D file missing: {rel}")
    actual = blob_sha(path)
    if actual != expected:
        fail(f"protected A12D boundary drift: {rel} expected {expected} got {actual}")

content = {name: read(path) for name, path in FILES.items()}
progress = content["progress"]
player = content["player"]
catalog = content["catalog"]
progress_test = content["progress_test"]
catalog_test = content["catalog_test"]
journal_test = content["journal_test"]
value_map = content["value_map"]
b5a2 = content["b5a2"]
b5b2p = content["b5b2p"]
bw54 = content["bw54"]

for needle in (
    "this.journalNote = ''",
    "final String journalNote;",
    "ChristianJourneyProgress withJournalNote",
    "journalNote: note.trim()",
    "'journalNote': journalNote",
    "map['journalNote']",
):
    if needle not in progress:
        fail(f"private journal progress contract missing: {needle}")

# The note must survive all state transitions and old records must default safely.
if progress.count("journalNote: journalNote") < 3:
    fail("journal note is not preserved across begin/complete/restart")

for needle in (
    "christian-journey-private-journal",
    "christian-journey-journal-note",
    "christian-journal-save",
    "christian-journal-clear",
    "Private journal note (optional)",
    "Saved only on this device with this journey.",
    "not included in Recovery Reports or exports",
    "currentStep.kind ==",
    "ChristianJourneyStepKind.reflection",
    "progress.withJournalNote(",
):
    if needle not in player:
        fail(f"private journal player contract missing: {needle}")

for forbidden in (
    "SharePlus",
    "RecoveryReportSnapshot",
    "RecoveryReportFormatter",
    "Clipboard.setData",
    "launchUrl",
    "http",
):
    if forbidden in player:
        fail(f"private journal has forbidden sharing/report/network coupling: {forbidden}")

journey_ids = re.findall(
    r"ChristianRecoveryJourney\(\s*id: '([^']+)'",
    catalog,
)
if len(journey_ids) != 7 or len(set(journey_ids)) != 7:
    fail(f"expected exactly seven unique Christian journeys, found {journey_ids}")

for needle in (
    "id: 'rebuild-trust-with-honesty'",
    "title: 'Rebuild trust with honesty'",
    "scriptureReference: 'James 1:19'",
    "Trust cannot be demanded",
    "controls their response, boundaries, timing, and forgiveness",
    "professional or pastoral guidance",
    "Open personal recovery plan",
    "humility and patience",
):
    if needle not in catalog:
        fail(f"relationship-repair contract missing: {needle}")

for forbidden in (
    "guaranteed repair",
    "must forgive",
    "demand forgiveness",
    "you owe disclosure",
    "a real christian would",
):
    if forbidden in catalog.lower():
        fail(f"relationship-repair coercive/unsafe wording found: {forbidden}")

for needle in (
    "private journal note is backward compatible and survives restart",
    "store saves and restores the private journey note",
):
    if needle not in progress_test:
        fail(f"progress regression coverage missing: {needle}")

for needle in (
    "catalog contains seven complete Christian journeys",
    "relationship repair journey protects agency and safety",
):
    if needle not in catalog_test:
        fail(f"catalog regression coverage missing: {needle}")

for needle in (
    "private journal appears only on Reflection and saves locally",
    "non-reflection step does not show private journal",
    "christian-journey-private-journal",
):
    if needle not in journal_test:
        fail(f"journal widget regression coverage missing: {needle}")

for needle in (
    "BreakWave Plus — Current Value Map",
    "Current delivered Plus value",
    "Six repeatable routines are delivered",
    "Rebuild trust with honesty",
    "optional private journal note",
    "not included in Recovery Reports or exports",
    "Major recovery-feature development should remain frozen after BW-89A12F",
    "does **not** authorize charging users",
    "Do not hardcode or advertise a launch price",
):
    if needle not in value_map:
        fail(f"current value-map contract missing: {needle}")

for forbidden in (
    "$59.99/year",
    "$8.99/month",
    "weekend risk plan",
    "secrecy breaker\n",
    "what helps recovery happen fastest",
    "Before the Google Play Developer account exists",
):
    if forbidden.lower() in value_map.lower():
        fail(f"stale/aspirational value-wall copy remains: {forbidden}")

for needle in (
    "len(journey_ids) != 7",
    "expected 7 journeys",
    "rebuild-trust-with-honesty",
    "James 1:19",
    "catalog contains seven complete Christian journeys",
):
    if needle not in b5a2:
        fail(f"historical B5A2 verifier not reconciled: {needle}")

for needle in (
    "len(when_values) != 7",
    "expected 7 ",
    "secrecy, broken promises, or a slip has affected trust in an important relationship.",
):
    if needle not in b5b2p:
        fail(f"historical B5B2P verifier not reconciled: {needle}")

for needle in (
    "Current pre-billing status:",
    "BreakWave Plus — Current Value Map",
    "Major recovery-feature development should remain frozen after BW-89A12F",
):
    if needle not in bw54:
        fail(f"historical BW54 verifier not reconciled: {needle}")

# Journal notes are private by design and must not enter any report/export layer.
for rel in (
    "lib/features/recovery_report/domain/recovery_report_selection.dart",
    "lib/features/recovery_report/domain/recovery_report_snapshot.dart",
    "lib/features/recovery_report/domain/recovery_report_snapshot_builder.dart",
    "lib/features/recovery_report/domain/recovery_report_formatter.dart",
    "lib/features/recovery_report/data/recovery_report_export_service.dart",
):
    text = read(ROOT / rel)
    if "journalNote" in text or "journal note" in text.lower():
        fail(f"private Christian journal leaked into report/export layer: {rel}")

print(
    "PASS: BW-89A12F Christian Depth paid-value closeout verified — optional "
    "local Reflection journaling, one safe relationship-repair journey, truthful "
    "current Plus value map, no Recovery Report/export/billing/access-policy drift, "
    "and historical Christian/value-wall verifier contracts reconciled."
)
