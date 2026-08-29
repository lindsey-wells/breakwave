#!/usr/bin/env python3
"""Verify WP-03S RevenueCat SDK bootstrap without requiring Flutter locally."""
from pathlib import Path
import hashlib
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

PUBSPEC = ROOT / "pubspec.yaml"
MANIFEST = ROOT / "android/app/src/main/AndroidManifest.xml"
MAIN = ROOT / "lib/main.dart"
BOOTSTRAP = ROOT / "lib/core/billing/revenuecat_bootstrap.dart"
DOC = ROOT / "docs/BW_WP03S_REVENUECAT_SDK_BOOTSTRAP.md"

ACCESS_HASHES = {
    "lib/core/access/breakwave_entitlement_source.dart":
        "f4270c554ef54b12b8ddce2b26c03a5d417f3e8fb52d62c94d812ea80f91961b",
    "lib/core/access/local_premium_entitlement_source.dart":
        "271d4b81085be5f3d4710040d34051b310d2ea8588ea638d1709a751e198b32f",
    "lib/core/access/breakwave_access_service.dart":
        "6d01c27bfb378ca76d304ed2d69f705a76a4675d6f2fc4da12f220ac1b2317cb",
}

def fail(msg: str) -> None:
    print(f"BW-WP03S VERIFY: FAIL — {msg}")
    raise SystemExit(1)

def text(path: Path) -> str:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")

def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

pubspec = text(PUBSPEC)
manifest = text(MANIFEST)
main = text(MAIN)
bootstrap = text(BOOTSTRAP)
doc = text(DOC)

if not re.search(r"(?m)^\s*purchases_flutter:\s*10\.10\.1\s*$", pubspec):
    fail("purchases_flutter is not exactly pinned to 10.10.1")

billing_permission = (
    '<uses-permission android:name="com.android.vending.BILLING"/>'
)
if manifest.count(billing_permission) != 1:
    fail("Android BILLING permission must appear exactly once")

for marker in (
    "package:purchases_flutter/purchases_flutter.dart",
    "BREAKWAVE_REVENUECAT_ANDROID_PUBLIC_SDK_KEY",
    "defaultTargetPlatform != TargetPlatform.android",
    "Purchases.isConfigured",
    "Purchases.setLogLevel",
    "LogLevel.debug",
    "LogLevel.info",
    "PurchasesConfiguration(_androidPublicSdkKey)",
    "Purchases.configure(configuration)",
    "Billing failure must never become recovery failure",
):
    if marker not in bootstrap:
        fail(f"bootstrap marker missing: {marker}")

for marker in (
    "import 'dart:async';",
    "revenuecat_bootstrap.dart",
    "runApp(const BreakWaveApp());",
    "unawaited(RevenueCatBootstrap.initialize());",
):
    if marker not in main:
        fail(f"main bootstrap marker missing: {marker}")

if main.index("runApp(const BreakWaveApp());") > main.index(
    "unawaited(RevenueCatBootstrap.initialize());"
):
    fail("RevenueCat must initialize after runApp")

for rel, expected in ACCESS_HASHES.items():
    path = ROOT / rel
    if not path.is_file():
        fail(f"access seam missing: {rel}")
    actual = sha(path)
    if actual != expected:
        fail(f"WP-03S must not change existing access seam: {rel}")

# No purchase/restore/offer behavior belongs in this first SDK bootstrap slice.
all_added = bootstrap + "\n" + main
for forbidden in (
    "purchasePackage(",
    "purchaseStoreProduct(",
    "restorePurchases(",
    "syncPurchases(",
    "getOfferings(",
    "getCustomerInfo(",
    "addCustomerInfoUpdateListener(",
):
    if forbidden in all_added:
        fail(f"premature RevenueCat behavior found: {forbidden}")

# No real RevenueCat Google public key should be hard-coded in this slice.
for path in (PUBSPEC, MAIN, BOOTSTRAP, DOC):
    value = text(path)
    if re.search(r"\bgoog_[A-Za-z0-9_-]{10,}\b", value):
        fail(f"hard-coded RevenueCat Google SDK key found in {path.relative_to(ROOT)}")

# No server/service credential shape may appear in the new billing source.
for forbidden in (
    "service_account",
    "private_key",
    "client_email",
    "BEGIN PRIVATE KEY",
):
    if forbidden.lower() in bootstrap.lower():
        fail(f"credential-like material found in bootstrap: {forbidden}")

for marker in (
    "LOCAL CANDIDATE — CI REQUIRED",
    "pubspec.lock",
    "gray/blue Plus",
    "trusted RevenueCat entitlement source",
):
    if marker not in doc:
        fail(f"WP-03S document marker missing: {marker}")

print("BW-WP03S VERIFY: PASS")
print("RevenueCat Flutter SDK pin: 10.10.1")
print("Android BILLING permission: present")
print("RevenueCat bootstrap: optional Android-only")
print("App launch waits for RevenueCat: no")
print("Hard-coded RevenueCat Google SDK key: no")
print("Purchase/restore/offering behavior introduced: no")
print("Existing BreakWave entitlement/access seam changed: no")
print("Local Flutter executed: no")
print("CI still required: yes")
print("Next gate: push WP-03S branch and run Shadow CI")
