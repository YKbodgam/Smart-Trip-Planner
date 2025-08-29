plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.imperial.pathoria"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Required by Gradle 9.0+
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.imperial.pathoria"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }

        // release {
        //     isMinifyEnabled = true
        //     proguardFiles(
        //         getDefaultProguardFile("proguard-android-optimize.txt"),
        //         "proguard-rules.pro"
        //     )
        // }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // This dependency is used by the application.
    implementation("com.google.guava:guava:33.2.1-jre")

    // Use JUnit Jupiter for unit tests.
    testImplementation("org.junit.jupiter:junit-jupiter:5.11.0")

    // The org.jetbrains.kotlin.jvm plugin requires the kotlin-stdlib dependency.
    implementation(kotlin("stdlib"))
}