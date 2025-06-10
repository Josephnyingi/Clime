plugins {
    id("com.android.application")  // Apply Android application plugin

    // Apply the Google services plugin to enable Firebase
    id("com.google.gms.google-services")  // This is for Firebase services (Google Sign-In, Firebase Analytics, etc.)

    id("kotlin-android")  // Apply Kotlin plugin for Android development
    id("dev.flutter.flutter-gradle-plugin")  // Apply Flutter plugin for Android
}

android {
    ndkVersion = "27.0.12077973"  // Set the NDK version
    namespace = "com.example.anga"  // Set the app namespace
    compileSdk = 35 // Set compile SDK version to 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11  // Use Java 11 for compiling
        targetCompatibility = JavaVersion.VERSION_11  // Set target compatibility to Java 11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()  // Set Kotlin JVM target to Java 11
    }

    defaultConfig {
        applicationId = "com.example.anga"  // Unique application ID for your app
        minSdk = flutter.minSdkVersion  // Set min SDK version from Flutter config
        targetSdk = 35  // Set target SDK version
        versionCode = flutter.versionCode  // Use Flutter's version code
        versionName = flutter.versionName  // Use Flutter's version name
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")  // Use debug signing config for release
        }
    }
}

dependencies {
    // Import the Firebase Bill of Materials (BoM) for managing Firebase versions
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

    // Firebase Authentication SDK
    implementation("com.google.firebase:firebase-auth")

    // Firebase Analytics SDK
    implementation("com.google.firebase:firebase-analytics")
    implementation(project(":"))
    implementation(project(":"))
    implementation("com.android.support:support-annotations:28.0.0")
    implementation("androidx.annotation:annotation:1.9.1")
    implementation("com.android.support:support-v4:28.0.0")

    // Add any other Firebase dependencies you need (like Firestore, Realtime Database, etc.)
}

flutter {
    source = "../.."  // Set the source path for Flutter
}

