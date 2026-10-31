import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load the Google Maps API key from a non-committed secrets file (or a
// MAPS_API_KEY environment variable in CI). Never hardcode the key in source.
val mapsApiKey: String = run {
    val secretsFile = rootProject.file("secrets.properties")
    val secrets = Properties()
    if (secretsFile.exists()) {
        FileInputStream(secretsFile).use { secrets.load(it) }
    }
    secrets.getProperty("MAPS_API_KEY")
        ?: System.getenv("MAPS_API_KEY")
        ?: ""
}

android {
    namespace = "com.r3recymed.aparcabicis"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications usa APIs de java.time: hacen falta las
        // librerías desugaradas para que funcione en Android antiguos.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.r3recymed.aparcabicis"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Injected into AndroidManifest.xml as ${MAPS_API_KEY}.
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Multi-ciudad (RF-0): un flavor por ciudad. Cada ciudad publica un binario
    // con su propio applicationId. El slug de ciudad se pasa además a Dart con
    // `--dart-define=CITY=<slug>` (ver lib/config/app_flavor.dart).
    //   flutter run --flavor demo --dart-define=CITY=demo
    flavorDimensions += "city"
    productFlavors {
        create("demo") {
            dimension = "city"
            applicationIdSuffix = ".demo"
            versionNameSuffix = "-demo"
            resValue("string", "app_name", "Aparcabicis Demo")
        }
        create("palma") {
            dimension = "city"
            applicationIdSuffix = ".palma"
            versionNameSuffix = "-palma"
            resValue("string", "app_name", "Aparcabicis Palma")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Requerido por flutter_local_notifications (core library desugaring).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
