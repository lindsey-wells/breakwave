from pathlib import Path
import re
import sys

catalog_path = Path(
    "lib/features/faith/domain/"
    "christian_recovery_journey_catalog.dart"
)
test_path = Path(
    "test/christian_recovery_journey_catalog_test.dart"
)

for path in [catalog_path, test_path]:
    if not path.exists():
        print(f"FAIL BW-87B5A2 missing file: {path}")
        sys.exit(1)

catalog = catalog_path.read_text(encoding="utf-8")
tests = test_path.read_text(encoding="utf-8")

journey_ids = re.findall(
    r"ChristianRecoveryJourney\(\s*id: '([^']+)'",
    catalog,
)

if len(journey_ids) != 6:
    print(
        "FAIL BW-87B5A2 expected 6 journeys, "
        f"found {len(journey_ids)}"
    )
    sys.exit(1)

if len(set(journey_ids)) != 6:
    print("FAIL BW-87B5A2 journey IDs are not unique")
    sys.exit(1)

required_journeys = [
    "grace-after-a-slip",
    "renew-the-next-thought",
    "step-into-the-light",
    "answer-loneliness-with-presence",
    "practice-small-integrity",
    "guard-the-night",
]

for journey_id in required_journeys:
    if journey_id not in journey_ids:
        print(
            "FAIL BW-87B5A2 journey missing: "
            f"{journey_id}"
        )
        sys.exit(1)

for reference in [
    "Romans 8:1",
    "Romans 12:2",
    "James 5:16",
    "Psalm 34:18",
    "Luke 16:10",
    "Matthew 26:41",
]:
    if reference not in catalog:
        print(
            "FAIL BW-87B5A2 Scripture reference "
            f"missing: {reference}"
        )
        sys.exit(1)

for needle in [
    "Scripture references guide you to the passage.",
    "not a replacement for pastoral, medical, or professional care",
    "ChristianJourneyStepKind.scripture",
    "ChristianJourneyStepKind.context",
    "ChristianJourneyStepKind.reflection",
    "ChristianJourneyStepKind.action",
    "ChristianJourneyStepKind.prayer",
    "ChristianJourneyActionTarget.rescue",
    "ChristianJourneyActionTarget.personalPlan",
    "actionLabel: 'Open Rescue'",
    "actionLabel: 'Open personal recovery plan'",
    "static ChristianRecoveryJourney? findById",
]:
    if needle not in catalog:
        print(
            "FAIL BW-87B5A2 catalog missing: "
            f"{needle}"
        )
        sys.exit(1)

for needle in [
    "catalog contains six complete Christian journeys",
    "journey and step identifiers are unique",
    "catalog prepares Rescue and personal plan actions",
    "catalog lookup returns the requested journey",
]:
    if needle not in tests:
        print(
            "FAIL BW-87B5A2 tests missing: "
            f"{needle}"
        )
        sys.exit(1)

combined = (catalog + tests).lower()

for forbidden in [
    "guaranteed freedom",
    "faith replaces therapy",
    "professional help is unnecessary",
    "a real christian would",
    "god is punishing you",
    "you failed god",
]:
    if forbidden in combined:
        print(
            "FAIL BW-87B5A2 unsafe or shaming claim "
            f"found: {forbidden}"
        )
        sys.exit(1)

print(
    "PASS: BW-87B5A2 six complete Christian "
    "recovery journeys and action targets verified."
)
