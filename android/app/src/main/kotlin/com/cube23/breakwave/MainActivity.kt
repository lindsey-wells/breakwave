package com.cube23.breakwave

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_PRIVACY_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setScreenPrivacyEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setScreenPrivacyEnabled(enabled)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setScreenPrivacyEnabled(enabled: Boolean) {
        if (enabled) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    companion object {
        private const val SCREEN_PRIVACY_CHANNEL = "breakwave/screen_privacy"
    }
}
