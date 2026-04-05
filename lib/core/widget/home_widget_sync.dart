// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: home_widget_sync.dart
// Purpose: BW-29 home widget sync helper.
// Notes: Saves lightweight widget state and requests widget updates.
// ------------------------------------------------------------

import 'package:home_widget/home_widget.dart';

import '../bedtime/bedtime_mode_entry.dart';
import '../bedtime/bedtime_mode_store.dart';
import '../checkin/daily_check_in_entry.dart';
import '../checkin/daily_check_in_store.dart';

class BreakWaveHomeWidgetSync {
  static const String providerName = 'BreakWaveHomeWidgetProvider';

  static Future<void> sync() async {
    final DailyCheckInEntry? todayCheckIn =
        await DailyCheckInStore.loadTodayEntry();
    final BedtimeModeEntry? tonightRisk =
        await BedtimeModeStore.loadTodayEntry();

    final String title = tonightRisk?.isRisky == true
        ? 'Tonight feels risky'
        : 'BreakWave';

    final String status = todayCheckIn == null
        ? 'No daily check-in saved yet.'
        : 'Today: ${todayCheckIn.status}';

    final String focus = tonightRisk?.isRisky == true
        ? 'Open BreakWave and go to Rescue.'
        : 'Ride the next wave clean.';

    await HomeWidget.saveWidgetData<String>('bw_widget_title', title);
    await HomeWidget.saveWidgetData<String>('bw_widget_status', status);
    await HomeWidget.saveWidgetData<String>('bw_widget_focus', focus);

    await HomeWidget.updateWidget(
      name: providerName,
    );
  }
}
