package com.cube23.breakwave

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        applyScreenPrivacyLaunchGuard()
        super.onCreate(savedInstanceState)
    }

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SOCIAL_LINKS_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openDefaultBrowser" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.success(false)
                    } else {
                        result.success(openDefaultBrowser(url))
                    }
                }
                "openUrlInPackage" -> {
                    val url = call.argument<String>("url")
                    val packageName = call.argument<String>("packageName")
                    if (url.isNullOrBlank() || packageName.isNullOrBlank()) {
                        result.success(false)
                    } else {
                        result.success(openUrlInPackage(url, packageName))
                    }
                }
                "openBrowserChooser" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.success(false)
                    } else {
                        result.success(openBrowserChooser(url))
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NOTIFICATION_SETTINGS_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> {
                    result.success(openNotificationSettings())
                }
                "openAppSettings" -> {
                    result.success(openAppSettings())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun applyScreenPrivacyLaunchGuard() {
        setScreenPrivacyEnabled(readStoredScreenPrivacyEnabled())
    }

    private fun readStoredScreenPrivacyEnabled(): Boolean {
        return try {
            val preferences = getSharedPreferences(
                FLUTTER_SHARED_PREFERENCES,
                MODE_PRIVATE
            )
            val raw = preferences.getString(
                FLUTTER_PRIVACY_SETTINGS_KEY,
                null
            )

            // A missing/corrupt startup state is intentionally fail-secure.
            // Flutter reconciles its actual saved/default setting asynchronously.
            if (raw.isNullOrBlank()) {
                true
            } else {
                JSONObject(raw).optBoolean(
                    SCREEN_PRIVACY_JSON_KEY,
                    false
                )
            }
        } catch (_: Exception) {
            true
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

    private fun openDefaultBrowser(url: String): Boolean {
        return try {
            val defaultBrowserProbe = Intent(
                Intent.ACTION_VIEW,
                Uri.parse("https://www.example.com")
            ).apply {
                addCategory(Intent.CATEGORY_BROWSABLE)
            }

            val defaultPackage = packageManager
                .resolveActivity(defaultBrowserProbe, PackageManager.MATCH_DEFAULT_ONLY)
                ?.activityInfo
                ?.packageName

            if (defaultPackage.isNullOrBlank() || defaultPackage == "android") {
                false
            } else {
                openUrlInPackage(url, defaultPackage)
            }
        } catch (_: Exception) {
            false
        }
    }

    private fun openUrlInPackage(url: String, packageName: String): Boolean {
        return try {
            val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                addCategory(Intent.CATEGORY_BROWSABLE)
                setPackage(packageName)
            }
            startActivity(browserIntent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openBrowserChooser(url: String): Boolean {
        return try {
            val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                addCategory(Intent.CATEGORY_BROWSABLE)
            }
            val chooser = Intent.createChooser(webIntent, "Open web link")
            startActivity(chooser)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openNotificationSettings(): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            openAppSettings()
        }
    }

    private fun openAppSettings(): Boolean {
        return try {
            val intent = Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    companion object {
        private const val SCREEN_PRIVACY_CHANNEL = "breakwave/screen_privacy"
        private const val FLUTTER_SHARED_PREFERENCES = "FlutterSharedPreferences"
        private const val FLUTTER_PRIVACY_SETTINGS_KEY = "flutter.bw_privacy_settings_v1"
        private const val SCREEN_PRIVACY_JSON_KEY = "blockScreenshotsAndScreenRecording"
        private const val SOCIAL_LINKS_CHANNEL = "breakwave/social_links"
        private const val NOTIFICATION_SETTINGS_CHANNEL = "breakwave/notification_settings"
    }
}
