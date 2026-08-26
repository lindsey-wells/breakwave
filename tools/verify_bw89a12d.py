#!/usr/bin/env python3
from __future__ import annotations

import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

FILES = {
    "template": ROOT / "lib/features/recovery_report/domain/accountability_check_in_template.dart",
    "card": ROOT / "lib/features/recovery_report/presentation/widgets/accountability_check_in_card.dart",
    "screen": ROOT / "lib/features/recovery_report/presentation/recovery_report_builder_screen.dart",
    "template_test": ROOT / "test/accountability_check_in_template_test.dart",
    "card_test": ROOT / "test/accountability_check_in_card_test.dart",
}

PROTECTED_BLOBS = {
    "lib/features/recovery_report/domain/recovery_report_selection.dart": "7577b83ac3b561a53d85df1f7a495fc4a45be14c",
    "lib/features/recovery_report/domain/recovery_report_snapshot.dart": "7dc59e8a6e05d6eca343eada21c9a6b68ec50ae6",
    "lib/features/recovery_report/domain/recovery_report_snapshot_builder.dart": "5ae104883c65af034953d7d1c0c86d93e54bd817",
    "lib/features/recovery_report/domain/recovery_report_formatter.dart": "d081cd67d9526e40f357149653dca984abe75b33",
    "lib/features/recovery_report/data/recovery_report_export_service.dart": "f87a44d5b7d1e8924f23c508ebf89fc1f2ba992a",
    "lib/core/support/support_contact_actions.dart": "474e79da7b4d991ed7dbc7923f6ffa23419bac87",
    "lib/features/support/presentation/widgets/support_quick_actions_card.dart": "ae93099b9e8a3f2a8b4a71fc58be152330b5dd40",
    "lib/core/access/breakwave_access_policy.dart": "65a276c022d2d802f306f0980214cee072825a9a",
    "lib/features/premium/presentation/breakwave_plus_screen.dart": "59b5424c86c93dd3b2e4e9788f4bfd9e673329f8",
    "tools/verify_bw89a12c.py": "d7ced3efff1f17531e5c69ed6db30a6ff3485128",
}


def fail(message: str) -> None:
    raise SystemExit(f"FAIL BW-89A12D: {message}")


def read(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def blob_sha(path: Path) -> str:
    data = path.read_bytes()
    header = f"blob {len(data)}\0".encode()
    return hashlib.sha1(header + data).hexdigest()


for rel, expected in PROTECTED_BLOBS.items():
    path = ROOT / rel
    if not path.is_file():
        fail(f"protected A12C file missing: {rel}")
    actual = blob_sha(path)
    if actual != expected:
        fail(
            f"protected A12C boundary drift: {rel} "
            f"expected {expected} got {actual}"
        )

content = {key: read(path) for key, path in FILES.items()}
template = content["template"]
card = content["card"]
screen = content["screen"]
template_test = content["template_test"]
card_test = content["card_test"]

for needle in (
    "enum AccountabilityCheckInTemplate",
    "weeklyCheckIn",
    "afterSlipHonesty",
    "victoryUpdate",
    "Weekly check-in",
    "After-slip honesty",
    "Victory update",
    "String get starterText",
):
    if needle not in template:
        fail(f"template contract missing: {needle}")

for needle in (
    "class AccountabilityCheckInCard",
    "TextEditingController",
    "ChoiceChip",
    "TextField(",
    "Clipboard.setData",
    "Copy message",
    "Reset",
    "nothing is sent automatically",
    "does not add recovery or report data",
    "stays separate from the recovery-report TXT and JSON files",
):
    if needle not in card:
        fail(f"card contract missing: {needle}")

for forbidden in (
    "LogRepository",
    "LogEntry",
    "RecoveryReportSnapshot",
    "RecoveryReportFormatter",
    "SupportContact",
    "SupportContactStore",
    "SharedPreferences",
    "url_launcher",
    "SharePlus",
    "launchUrl",
    "http",
):
    if forbidden.lower() in card.lower():
        fail(f"card forbidden automatic data/send coupling: {forbidden}")

for needle in (
    "widgets/accountability_check_in_card.dart",
    "const AccountabilityCheckInCard()",
):
    if needle not in screen:
        fail(f"Recovery Report integration missing: {needle}")

for forbidden in (
    "Clipboard.setData",
    "AccountabilityCheckInTemplate.",
):
    if forbidden in screen:
        fail(f"composer logic leaked into report screen: {forbidden}")

for needle in (
    "exactly three editable accountability starters",
    "hasLength(3)",
    "Weekly check-in",
    "After-slip honesty",
    "Victory update",
):
    if needle not in template_test:
        fail(f"template regression coverage missing: {needle}")

for needle in (
    "template can be selected edited and reset locally",
    "accountability-check-in-editor",
    "accountability-template-afterSlipHonesty",
    "accountability-reset-template",
    "accountability-copy-message",
):
    if needle not in card_test:
        fail(f"card regression coverage missing: {needle}")

print(
    "PASS: BW-89A12D Accountability Check-In Templates verified — three "
    "editable copy-only local templates, explicit user control, no automatic "
    "send or recovery-data injection, report/export schema unchanged, and "
    "A12C plus Free support boundaries preserved."
)
