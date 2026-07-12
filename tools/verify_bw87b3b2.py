from pathlib import Path
import sys

prefill_path = Path(
    "lib/features/personal_plan/domain/"
    "personal_recovery_plan_prefill.dart"
)
foundation_test_path = Path(
    "test/personal_recovery_plan_test.dart"
)
refresh_test_path = Path(
    "test/personal_recovery_plan_refresh_test.dart"
)

for path in [
    prefill_path,
    foundation_test_path,
    refresh_test_path,
]:
    if not path.exists():
        print(f"FAIL BW-87B3B2 missing file: {path}")
        sys.exit(1)

prefill = prefill_path.read_text(encoding="utf-8")
foundation_tests = foundation_test_path.read_text(
    encoding="utf-8"
)
refresh_tests = refresh_test_path.read_text(
    encoding="utf-8"
)

for needle in [
    "BW-87B3B2 maps saved Why to the main reason",
    "savedWhy.isNotEmpty",
    "? savedWhy",
    ": savedFocus",
    "final String previousTrimmed",
    "if (previousTrimmed.isEmpty)",
    "nextTrimmed.isNotEmpty",
]:
    if needle not in prefill:
        print(
            f"FAIL BW-87B3B2 Why/contact mapping missing: "
            f"{needle}"
        )
        sys.exit(1)

for forbidden in [
    "if (savedWhy.isNotEmpty) savedWhy",
]:
    if forbidden in prefill:
        print(
            f"FAIL BW-87B3B2 saved Why still duplicated "
            f"into reasons: {forbidden}"
        )
        sys.exit(1)

for needle in [
    "'I want my life back.'",
    "legacy imported Why and contact refresh when metadata is missing",
    "'Mi familia'",
    "'Sam'",
    "isNot(contains('A new saved Why'))",
]:
    combined = foundation_tests + refresh_tests

    if needle not in combined:
        print(
            f"FAIL BW-87B3B2 regression coverage missing: "
            f"{needle}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B3B2 saved Why and trusted-contact "
    "refresh mapping verified."
)
