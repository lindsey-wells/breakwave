import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()

if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// WP-03V-T2: Android identity isolation for the RevenueCat Test Store QA APK.
// Normal builds do not set this Gradle property and retain the Play identity.
val breakWaveTestStoreQa = providers.gradleProperty("breakwaveTestStoreQa")
    .orNull
    ?.trim()
    ?.equals("true", ignoreCase = true) == true

val breakWaveApplicationId = if (breakWaveTestStoreQa) {
    "com.cube23.breakwave.teststoreqa"
} else {
    "com.cube23.breakwave"
}

val breakWaveAppLabel = if (breakWaveTestStoreQa) {
    "BreakWave Test Store"
} else {
    "BreakWave"
}

android {
    namespace = "com.cube23.breakwave"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Production Play identity is the default. T2 QA opts into a separate
        // installable identity using ORG_GRADLE_PROJECT_breakwaveTestStoreQa.
        applicationId = breakWaveApplicationId
        manifestPlaceholders["breakWaveAppLabel"] = breakWaveAppLabel

        // Version values come from pubspec.yaml through Flutter.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
