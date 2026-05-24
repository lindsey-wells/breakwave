from pathlib import Path
import sys

path = Path("pubspec.yaml")
text = path.read_text(encoding="utf-8")

failed = False

if "home_widget: 0.7.0+1" not in text:
    print("FAIL pubspec.yaml must pin home_widget: 0.7.0+1")
    failed = True

blocked = [
    "home_widget: ^0.9",
    "home_widget: 0.9",
    "home_widget: ^0.8",
    "home_widget: 0.8",
]

for needle in blocked:
    if needle in text:
        print(f"FAIL pubspec.yaml still contains blocked dependency: {needle}")
        failed = True

if failed:
    sys.exit(1)

print("PASS: BW-46B home_widget pinned to pre-Glance-alpha release line.")
