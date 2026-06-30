package com.cube23.breakwave

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
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

    companion object {
        private const val SCREEN_PRIVACY_CHANNEL = "breakwave/screen_privacy"
        private const val SOCIAL_LINKS_CHANNEL = "breakwave/social_links"
    }
}
