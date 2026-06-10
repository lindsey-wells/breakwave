# BreakWave — BW-68 GitHub Actions Node 24 Readiness

## Purpose

BW-68 prepares BreakWave CI for GitHub Actions' Node.js 24 runner transition.

## Changes

- Opts workflows into Node.js 24 JavaScript actions with FORCE_JAVASCRIPT_ACTIONS_TO_NODE24.
- Upgrades the main CI Java setup action from actions/setup-java@v4 to actions/setup-java@v5.
- Keeps the existing Flutter verification, tests, APK build, and AAB build pipeline unchanged.

## Reason

GitHub Actions warned that Node.js 20 JavaScript actions are deprecated and will be forced to Node.js 24 by default. This pass opts in early so BreakWave release builds do not surprise-fail later.
