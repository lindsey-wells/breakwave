// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_performance_probe.dart
// Purpose: QA-only, read-only performance instrumentation.
// Notes: No billing authority, purchase, restore, or catalog behavior.
// ------------------------------------------------------------

import 'dart:io';
import 'dart:ui' show FrameTiming;

import 'package:flutter/scheduler.dart';

class BreakWavePerformanceSample {
  const BreakWavePerformanceSample({
    required this.category,
    required this.name,
    required this.durationMicroseconds,
    required this.rssBytes,
    required this.recordedAtUtc,
  });

  final String category;
  final String name;
  final int durationMicroseconds;
  final int rssBytes;
  final DateTime recordedAtUtc;

  double get durationMilliseconds => durationMicroseconds / 1000.0;
}

class BreakWavePerformanceSnapshot {
  const BreakWavePerformanceSnapshot({
    required this.samples,
    required this.currentRssBytes,
    required this.frameCount,
    required this.framesOver16Ms,
    required this.framesOver33Ms,
    required this.maxFrameMicroseconds,
    required this.averageBuildMicroseconds,
    required this.averageRasterMicroseconds,
  });

  final List<BreakWavePerformanceSample> samples;
  final int currentRssBytes;
  final int frameCount;
  final int framesOver16Ms;
  final int framesOver33Ms;
  final int maxFrameMicroseconds;
  final double averageBuildMicroseconds;
  final double averageRasterMicroseconds;
}

class BreakWavePerformanceProbe {
  const BreakWavePerformanceProbe._();

  static const bool enabled = bool.fromEnvironment(
    'BREAKWAVE_REVENUECAT_TEST_STORE_QA',
    defaultValue: false,
  );

  static const int _maxSamples = 80;
  static final List<BreakWavePerformanceSample> _samples =
      <BreakWavePerformanceSample>[];

  static bool _frameObserverInstalled = false;
  static int _frameCount = 0;
  static int _framesOver16Ms = 0;
  static int _framesOver33Ms = 0;
  static int _maxFrameMicroseconds = 0;
  static int _totalBuildMicroseconds = 0;
  static int _totalRasterMicroseconds = 0;

  static Stopwatch startTimer() => Stopwatch()..start();

  static void installFrameTimingObserver() {
    if (!enabled || _frameObserverInstalled) return;
    SchedulerBinding.instance.addTimingsCallback(_handleFrameTimings);
    _frameObserverInstalled = true;
  }

  static void recordElapsed({
    required String category,
    required String name,
    required Stopwatch stopwatch,
  }) {
    if (!enabled) return;
    if (stopwatch.isRunning) stopwatch.stop();
    _record(
      category: category,
      name: name,
      durationMicroseconds: stopwatch.elapsedMicroseconds,
    );
  }

  static BreakWavePerformanceSnapshot snapshot() {
    final int frameCount = _frameCount;
    return BreakWavePerformanceSnapshot(
      samples: List<BreakWavePerformanceSample>.unmodifiable(_samples),
      currentRssBytes: _safeCurrentRss(),
      frameCount: frameCount,
      framesOver16Ms: _framesOver16Ms,
      framesOver33Ms: _framesOver33Ms,
      maxFrameMicroseconds: _maxFrameMicroseconds,
      averageBuildMicroseconds:
          frameCount == 0 ? 0 : _totalBuildMicroseconds / frameCount,
      averageRasterMicroseconds:
          frameCount == 0 ? 0 : _totalRasterMicroseconds / frameCount,
    );
  }

  static void _handleFrameTimings(List<FrameTiming> timings) {
    if (!enabled) return;
    for (final FrameTiming timing in timings) {
      final int total = timing.totalSpan.inMicroseconds;
      final int build = timing.buildDuration.inMicroseconds;
      final int raster = timing.rasterDuration.inMicroseconds;
      _frameCount += 1;
      _totalBuildMicroseconds += build;
      _totalRasterMicroseconds += raster;
      if (total > _maxFrameMicroseconds) _maxFrameMicroseconds = total;
      if (total > 16667) _framesOver16Ms += 1;
      if (total > 33333) _framesOver33Ms += 1;
    }
  }

  static void _record({
    required String category,
    required String name,
    required int durationMicroseconds,
  }) {
    _samples.add(
      BreakWavePerformanceSample(
        category: category,
        name: name,
        durationMicroseconds: durationMicroseconds,
        rssBytes: _safeCurrentRss(),
        recordedAtUtc: DateTime.now().toUtc(),
      ),
    );
    if (_samples.length > _maxSamples) {
      _samples.removeRange(0, _samples.length - _maxSamples);
    }
  }

  static int _safeCurrentRss() {
    try {
      return ProcessInfo.currentRss;
    } catch (_) {
      return 0;
    }
  }
}
