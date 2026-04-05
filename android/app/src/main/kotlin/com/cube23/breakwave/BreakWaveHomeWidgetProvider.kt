package com.cube23.breakwave

// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: BreakWaveHomeWidgetProvider.kt
// Purpose: BW-29 Android home widget provider.
// Notes: Simple BreakWave widget with one-tap app launch.
// ------------------------------------------------------------

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BreakWaveHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.breakwave_home_widget).apply {
                val title = widgetData.getString("bw_widget_title", "BreakWave")
                val status = widgetData.getString("bw_widget_status", "No daily check-in saved yet.")
                val focus = widgetData.getString("bw_widget_focus", "Open BreakWave")

                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_status, status)
                setTextViewText(R.id.widget_focus, focus)

                val launchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("breakwave://open")
                )

                setOnClickPendingIntent(R.id.widget_root, launchIntent)
                setOnClickPendingIntent(R.id.widget_open_button, launchIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
