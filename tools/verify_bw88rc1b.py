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
    return (
        ROOT / path
    ).read_text(encoding="utf-8")


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
        (
            "lib/core/branding/"
            "breakwave_wordmark.dart"
        ),
        [
            "class BreakWaveWordmark",
            "static const String assetPath",
            (
                "assets/branding/"
                "breakwave_in_app_header.png"
            ),
            "static const String semanticLabel",
            "BreakWave brand wordmark",
            "widgetKey",
            "semanticsKey",
            "imageKey",
            "Semantics(",
            "container: true",
            "excludeSemantics: true",
            "Image.asset(",
            "errorBuilder:",
            "fontWeight: FontWeight.w900",
            "letterSpacing: -0.8",
        ],
    )

    require_text(
        failures,
        "lib/core/ui/breakwave_app_bar.dart",
        [
            (
                "import '../branding/"
                "breakwave_wordmark.dart';"
            ),
            "class BreakWaveAppBar",
            "BreakWaveWordmark(",
            "width: 240",
            "height: 52",
            "sectionTitle",
        ],
    )

    require_text(
        failures,
        (
            "lib/core/privacy/"
            "breakwave_privacy_policy.dart"
        ),
        [
            "class BreakWavePrivacyPolicy",
            "https://breakwaveapp.com/#privacy",
            "static final Uri uri",
            "class BreakWavePrivacyPolicyButton",
            "breakwave_privacy_policy_button",
            "Read Privacy Policy",
            "Icons.policy_outlined",
        ],
    )

    support_path = (
        "lib/features/support/presentation/"
        "widgets/breakwave_contact_links_card.dart"
    )

    require_text(
        failures,
        support_path,
        [
            (
                "core/privacy/"
                "breakwave_privacy_policy.dart"
            ),
            "Future<void> _openPrivacyPolicy",
            "BreakWavePrivacyPolicy.uri",
            "_openSocialInDefaultBrowser(",
            "BreakWavePrivacyPolicyButton(",
        ],
    )

    require_text(
        failures,
        "test/widget_test.dart",
        [
            "BreakWave renders home shell",
            "find.text('BreakWave')",
            "find.text('Open Rescue')",
        ],
    )

    require_text(
        failures,
        "test/breakwave_wordmark_test.dart",
        [
            (
                "BreakWave wordmark uses approved "
                "asset and metadata"
            ),
            "BreakWaveWordmark.widgetKey",
            "BreakWaveWordmark.semanticsKey",
            "BreakWaveWordmark.imageKey",
            "tester.widget<Semantics>",
            "semantics.properties.label",
            "semantics.properties.image",
            "provider.assetName",
            "BreakWaveWordmark.assetPath",
            "image.errorBuilder",
        ],
    )

    require_text(
        failures,
        "test/breakwave_privacy_policy_test.dart",
        [
            (
                "Privacy Policy uses the "
                "published BreakWave URL"
            ),
            "BreakWavePrivacyPolicy.url",
            "BreakWavePrivacyPolicy.uri.toString()",
            (
                "BreakWavePrivacyPolicyButton."
                "widgetKey"
            ),
            "BreakWavePrivacyPolicy.buttonLabel",
            "Icons.policy_outlined",
            "expect(pressed, isTrue)",
        ],
    )

    widget_test = read("test/widget_test.dart")

    if "find.bySemanticsLabel" in widget_test:
        failures.append(
            "legacy widget smoke test still relies "
            "on merged semantics-tree lookup."
        )

    support_text = read(support_path)

    if "privacyPolicyUrl" in support_text:
        failures.append(
            "Support card retains duplicate "
            "privacyPolicyUrl constant."
        )

    if (
        "'https://breakwaveapp.com/#privacy'"
        in support_text
    ):
        failures.append(
            "Support card retains duplicate "
            "Privacy Policy URL literal."
        )

    app_bar_text = read(
        "lib/core/ui/breakwave_app_bar.dart"
    )

    if (
        "breakwave_in_app_header.png"
        in app_bar_text
    ):
        failures.append(
            "AppBar bypasses isolated wordmark "
            "helper with a direct asset path."
        )

    expected_assets = {
        SOURCE_ASSET: (2172, 724, 8, 2),
        FINAL_ASSET: (1392, 304, 8, 6),
    }

    for relative, expected in expected_assets.items():
        path = ROOT / relative

        if not path.is_file():
            failures.append(
                f"missing file: {relative}"
            )
            continue

        try:
            actual = png_info(path)
        except Exception as exc:
            failures.append(
                f"{relative} invalid: {exc}"
            )
            continue

        if actual != expected:
            failures.append(
                f"{relative}: expected {expected}, "
                f"got {actual}"
            )

    combined_header_text = (
        app_bar_text
        + read(
            "lib/core/branding/"
            "breakwave_wordmark.dart"
        )
    )

    for obsolete in [
        "_BreakWaveBrandMark",
        "_BreakWaveBrandPainter",
        "CustomPaint",
        "canvas.drawCircle",
    ]:
        if obsolete in combined_header_text:
            failures.append(
                "header retains obsolete painter: "
                f"{obsolete}"
            )

    website_index = support_text.find(
        "Visit breakwaveapp.com"
    )

    privacy_index = support_text.find(
        "BreakWavePrivacyPolicyButton("
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
            "isolated branding helper, accessible "
            "fallback metadata, canonical Privacy "
            "Policy helper, stable widget tests, "
            "version bump, and CI artifact checks "
            "are wired."
        )
    else:
        print(
            "BW-88RC1B release artifact passed: "
            f"{args.artifact}"
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
