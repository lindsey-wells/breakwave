#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
import struct
import sys
import zipfile

ROOT = Path.cwd()

SOURCE_ASSET = (
    "assets/branding/"
    "breakwave_in_app_header_source.png"
)

FINAL_ASSET = (
    "assets/branding/"
    "breakwave_in_app_header.png"
)

PACKAGED_SUFFIX = (
    "flutter_assets/assets/branding/"
    "breakwave_in_app_header.png"
)


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def png_info_bytes(
    data: bytes,
) -> tuple[int, int, int, int]:
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")

    if data[12:16] != b"IHDR":
        raise ValueError("missing PNG IHDR")

    return struct.unpack(
        ">IIBB",
        data[16:26],
    )


def png_info(
    path: Path,
) -> tuple[int, int, int, int]:
    return png_info_bytes(path.read_bytes())


def require_text(
    failures: list[str],
    path: str,
    needles: list[str],
) -> None:
    file_path = ROOT / path

    if not file_path.is_file():
        failures.append(f"missing file: {path}")
        return

    text = read(path)

    for needle in needles:
        if needle not in text:
            failures.append(
                f"{path} missing: {needle}"
            )


def verify_static() -> list[str]:
    failures: list[str] = []

    require_text(
        failures,
        "pubspec.yaml",
        [
            "version: 1.0.1+2",
            "assets:",
            (
                "- assets/branding/"
                "breakwave_in_app_header.png"
            ),
        ],
    )

    require_text(
        failures,
        "lib/core/ui/breakwave_app_bar.dart",
        [
            "_brandAssetPath",
            "Image.asset(",
            (
                "assets/branding/"
                "breakwave_in_app_header.png"
            ),
            "BreakWave brand wordmark",
            "Semantics(",
            "excludeSemantics: true",
            "errorBuilder:",
            "width: 240",
            "height: 52",
            "sectionTitle",
        ],
    )

    require_text(
        failures,
        (
            "lib/features/support/presentation/"
            "widgets/breakwave_contact_links_card.dart"
        ),
        [
            "privacyPolicyUrl =",
            "'https://breakwaveapp.com/#privacy'",
            "Future<void> _openPrivacyPolicy",
            "Uri.parse(privacyPolicyUrl)",
            "_openSocialInDefaultBrowser(",
            "Read Privacy Policy",
            "Icons.policy_outlined",
        ],
    )

    require_text(
        failures,
        "test/widget_test.dart",
        [
            (
                "find.bySemanticsLabel("
                "'BreakWave brand wordmark')"
            ),
        ],
    )

    require_text(
        failures,
        ".github/workflows/ci.yml",
        [
            "Verify BW-88RC1B in release APK",
            "Verify BW-88RC1B in release AAB",
            "python3 tools/verify_bw88rc1b.py",
        ],
    )

    expected_pngs = {
        SOURCE_ASSET: (2172, 724, 8, 2),
        FINAL_ASSET: (1392, 304, 8, 6),
    }

    for relative, expected in expected_pngs.items():
        path = ROOT / relative

        if not path.is_file():
            failures.append(
                f"missing PNG: {relative}"
            )
            continue

        try:
            actual = png_info(path)
        except Exception as exc:
            failures.append(
                f"{relative}: {exc}"
            )
            continue

        if actual != expected:
            failures.append(
                f"{relative}: expected {expected}, "
                f"got {actual}"
            )

    app_bar_text = read(
        "lib/core/ui/breakwave_app_bar.dart"
    )

    for obsolete in [
        "_BreakWaveBrandMark",
        "_BreakWaveBrandPainter",
        "CustomPaint",
        "canvas.drawCircle",
    ]:
        if obsolete in app_bar_text:
            failures.append(
                "app bar retains obsolete painter: "
                f"{obsolete}"
            )

    support_text = read(
        "lib/features/support/presentation/"
        "widgets/breakwave_contact_links_card.dart"
    )

    website_index = support_text.find(
        "Visit breakwaveapp.com"
    )
    privacy_index = support_text.find(
        "Read Privacy Policy"
    )
    support_email_index = support_text.find(
        "label: const Text(emailAddress)"
    )

    if not (
        website_index >= 0
        and privacy_index > website_index
        and support_email_index > privacy_index
    ):
        failures.append(
            "Privacy Policy button is not positioned "
            "between website and support email."
        )

    return failures


def verify_artifact(
    artifact: Path,
) -> list[str]:
    if not artifact.is_file():
        return [
            f"missing release artifact: {artifact}"
        ]

    try:
        with zipfile.ZipFile(artifact) as archive:
            matches = [
                name
                for name in archive.namelist()
                if name.endswith(PACKAGED_SUFFIX)
            ]

            if len(matches) != 1:
                return [
                    "expected exactly one packaged "
                    "BreakWave header asset in "
                    f"{artifact}; found {len(matches)}"
                ]

            asset_bytes = archive.read(matches[0])

    except Exception as exc:
        return [
            f"could not inspect {artifact}: {exc}"
        ]

    try:
        actual = png_info_bytes(asset_bytes)
    except Exception as exc:
        return [
            "packaged BreakWave header asset "
            f"is invalid: {exc}"
        ]

    expected = (1392, 304, 8, 6)

    if actual != expected:
        return [
            "packaged BreakWave header asset "
            f"expected {expected}, got {actual}"
        ]

    return []


def main() -> int:
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--artifact",
        type=Path,
    )

    args = parser.parse_args()

    failures = verify_static()

    if args.artifact is not None:
        failures.extend(
            verify_artifact(args.artifact)
        )

    if failures:
        print("BW-88RC1B verification failed:")

        for failure in failures:
            print(f" - {failure}")

        return 1

    if args.artifact is None:
        print(
            "BW-88RC1B verification passed: "
            "approved high-resolution wordmark, "
            "responsive header, accessible fallback, "
            "direct Privacy Policy access, version "
            "bump, and CI artifact checks are wired."
        )
    else:
        print(
            "BW-88RC1B release artifact passed: "
            f"{args.artifact}"
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
