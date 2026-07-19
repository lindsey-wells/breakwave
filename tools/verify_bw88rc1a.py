#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
import struct
import sys
import zipfile

ROOT = Path.cwd()


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def png_info(path: Path) -> tuple[int, int, int]:
    data = path.read_bytes()

    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")

    if data[12:16] != b"IHDR":
        raise ValueError("missing PNG IHDR")

    width, height, bit_depth, color_type = struct.unpack(
        ">IIBB",
        data[16:26],
    )

    if bit_depth != 8:
        raise ValueError(
            f"expected 8-bit PNG, got {bit_depth}"
        )

    return width, height, color_type


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
        "lib/features/support/presentation/widgets/"
        "breakwave_contact_links_card.dart",
        [
            "websiteUrl = 'https://breakwaveapp.com'",
            "Future<void> _openWebsite",
            "Visit breakwaveapp.com",
            "_openSocialInDefaultBrowser(",
        ],
    )

    require_text(
        failures,
        "lib/core/reminders/"
        "breakwave_notifications.dart",
        [
            "notificationIconName =",
            "'ic_stat_breakwave'",
            "fallbackNotificationIconName =",
            "'@mipmap/ic_launcher'",
            "useCustomIcon: true",
            "useCustomIcon: false",
            "icon: useCustomIcon "
            "? notificationIconName : null",
        ],
    )

    require_text(
        failures,
        "android/app/src/main/AndroidManifest.xml",
        [
            'android:icon="@mipmap/ic_launcher"',
            'android:roundIcon='
            '"@mipmap/ic_launcher_round"',
        ],
    )

    require_text(
        failures,
        "android/app/src/main/res/raw/keep.xml",
        [
            "@drawable/ic_stat_breakwave",
            "@mipmap/ic_launcher",
            "@mipmap/ic_launcher_round",
            "@mipmap/ic_launcher_foreground",
        ],
    )

    require_text(
        failures,
        ".github/workflows/ci.yml",
        [
            "Verify branded resources in release APK",
            "Verify branded resources in release AAB",
            "--artifact build/app/outputs/"
            "flutter-apk/app-release.apk",
            "--artifact build/app/outputs/"
            "bundle/release/app-release.aab",
            "name: breakwave-play-store-icon",
            "assets/branding/"
            "play_store_icon_512.png",
        ],
    )

    expected_pngs = {
        "assets/branding/"
        "breakwave_app_icon.png":
            (1024, 1024, 2),
        "assets/branding/"
        "breakwave_app_icon_adaptive_foreground.png":
            (1024, 1024, 6),
        "assets/branding/"
        "play_store_icon_512.png":
            (512, 512, 2),
        "assets/branding/"
        "breakwave_notification_icon.png":
            (512, 512, 6),
        "android/app/src/main/res/drawable/"
        "ic_stat_breakwave.png":
            (96, 96, 6),
    }

    density_sizes = {
        "mipmap-mdpi": (48, 108),
        "mipmap-hdpi": (72, 162),
        "mipmap-xhdpi": (96, 216),
        "mipmap-xxhdpi": (144, 324),
        "mipmap-xxxhdpi": (192, 432),
    }

    for directory, sizes in density_sizes.items():
        legacy_size, foreground_size = sizes

        expected_pngs[
            "android/app/src/main/res/"
            f"{directory}/ic_launcher.png"
        ] = (
            legacy_size,
            legacy_size,
            2,
        )

        expected_pngs[
            "android/app/src/main/res/"
            f"{directory}/ic_launcher_round.png"
        ] = (
            legacy_size,
            legacy_size,
            2,
        )

        expected_pngs[
            "android/app/src/main/res/"
            f"{directory}/ic_launcher_foreground.png"
        ] = (
            foreground_size,
            foreground_size,
            6,
        )

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

    for relative in [
        "android/app/src/main/res/"
        "mipmap-anydpi-v26/ic_launcher.xml",
        "android/app/src/main/res/"
        "mipmap-anydpi-v26/ic_launcher_round.xml",
        "android/app/src/main/res/values/"
        "breakwave_launcher_colors.xml",
    ]:
        if not (ROOT / relative).is_file():
            failures.append(
                f"missing resource: {relative}"
            )

    return failures


def verify_artifact(
    artifact: Path,
) -> list[str]:
    failures: list[str] = []

    if not artifact.is_file():
        return [
            f"missing release artifact: {artifact}"
        ]

    try:
        with zipfile.ZipFile(artifact) as archive:
            names = archive.namelist()

            if artifact.suffix == ".apk":
                candidates = [
                    name
                    for name in names
                    if name == "resources.arsc"
                ]
            elif artifact.suffix == ".aab":
                candidates = [
                    name
                    for name in names
                    if name.endswith("resources.pb")
                ]
            else:
                return [
                    "artifact must be APK or AAB: "
                    f"{artifact}"
                ]

            if not candidates:
                return [
                    "compiled resource table missing "
                    f"from {artifact}"
                ]

            resource_bytes = b"".join(
                archive.read(name)
                for name in candidates
            )
    except Exception as exc:
        return [
            f"could not inspect {artifact}: {exc}"
        ]

    for resource_name in [
        "ic_stat_breakwave",
        "ic_launcher",
    ]:
        utf8 = resource_name.encode("utf-8")
        utf16 = resource_name.encode("utf-16le")

        if (
            utf8 not in resource_bytes
            and utf16 not in resource_bytes
        ):
            failures.append(
                f"{artifact} stripped resource: "
                f"{resource_name}"
            )

    return failures


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
        print(
            "BW-88RC1A verification failed:"
        )

        for failure in failures:
            print(f" - {failure}")

        return 1

    if args.artifact is None:
        print(
            "BW-88RC1A verification passed: "
            "website, launcher, Play Store, "
            "notification icon, fallback, "
            "resource preservation, and CI "
            "artifact checks are wired."
        )
    else:
        print(
            "BW-88RC1A release artifact passed: "
            f"{args.artifact}"
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
