import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.pdm_malang"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Harus sama dengan package_name di android/app/google-services.json (Firebase).
        // Namespace Kotlin tetap com.example.pdm_malang (folder MainActivity).
        applicationId = "id.makotamu.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            val storeFileName = keystoreProperties.getProperty("storeFile")
            val alias = keystoreProperties.getProperty("keyAlias")
            val storePass = keystoreProperties.getProperty("storePassword")
            val keyPass = keystoreProperties.getProperty("keyPassword")
            if (storeFileName != null && alias != null && storePass != null && keyPass != null) {
                create("release") {
                    keyAlias = alias
                    keyPassword = keyPass
                    storeFile = rootProject.file(storeFileName)
                    storePassword = storePass
                }
            }
        }
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.findByName("release")
            signingConfig = releaseSigning
                ?: signingConfigs.getByName("debug")
            // Saat R8/minify aktif (release/obfuscate): Gson TypeToken di flutter_local_notifications.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
