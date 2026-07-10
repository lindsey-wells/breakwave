from pathlib import Path
import sys

text = Path(
    "lib/features/support/presentation/widgets/email_app_handoff_card.dart"
).read_text(encoding="utf-8")

required = [
    "const String subject = 'BreakWave feedback';",
    "const String body =",
    "Uri.parse(",
    "Uri.encodeComponent(subject)",
    "Uri.encodeComponent(body)",
    "?subject=",
    "&body=",
]

for needle in required:
    if needle not in text:
        print(f"FAIL BW-86D3 encoded feedback email missing: {needle}")
        sys.exit(1)

if "queryParameters: const <String, String>" in text:
    print("FAIL BW-86D3 old plus-producing mailto encoding remains")
    sys.exit(1)

print("PASS: BW-86D3 feedback email encoding verified.")
