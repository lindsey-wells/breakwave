from pathlib import Path
import sys

screen_path = Path(
    "lib/features/insights/presentation/recovery_insights_screen.dart"
)
plus_path = Path(
    "lib/features/premium/presentation/breakwave_plus_screen.dart"
)

for path in [screen_path, plus_path]:
    if not path.exists():
        print(f"FAIL BW-87B2B missing file: {path}")
        sys.exit(1)

screen = screen_path.read_text(encoding="utf-8")
plus = plus_path.read_text(encoding="utf-8")

for needle in [
    "class RecoveryInsightsScreen",
    "RecoveryInsightsCalculator",
    "RefreshIndicator",
    "Your last 7 days",
    "Last 30 days",
    "Last 90 days",
    "Top recorded triggers — 30 days",
    "Recorded timing patterns",
    "At least 5 valid entries in 30 days",
    "do not predict relapse",
    "saved on this device",
    "Try again",
]:
    if needle not in screen:
        print(f"FAIL BW-87B2B insights screen missing: {needle}")
        sys.exit(1)

for needle in [
    "BW-87B2B adds a working recovery insights preview.",
    "RecoveryInsightsScreen",
    "Preview recovery insights",
    "_openRecoveryInsights(context)",
]:
    if needle not in plus:
        print(f"FAIL BW-87B2B Plus integration missing: {needle}")
        sys.exit(1)

for forbidden in [
    "high risk",
    "likely to relapse",
    "predict your next",
]:
    if forbidden.lower() in screen.lower():
        print(f"FAIL BW-87B2B predictive language remains: {forbidden}")
        sys.exit(1)

print("PASS: BW-87B2B real Recovery Insights screen verified.")
