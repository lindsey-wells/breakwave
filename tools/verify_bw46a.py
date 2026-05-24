from pathlib import Path
import sys

path = Path("pubspec.yaml")
text = path.read_text(encoding="utf-8")

checks = [
    "home_widget: 0.8.1",
]

failed = False

for needle in checks:
    if needle not in text:
        print(f"FAIL pubspec.yaml missing: {needle}")
        failed = True

if "home_widget: ^0.9" in text or "home_widget: 0.9" in text:
    print("FAIL pubspec.yaml still allows home_widget 0.9.x")
    failed = True

if failed:
    sys.exit(1)

print("PASS: BW-46A home_widget dependency pinned below Glance alpha line.")
