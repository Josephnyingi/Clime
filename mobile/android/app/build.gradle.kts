// Removed unnecessary imports for implementation and kapt

plugins {
    id("com.android.application")  // Apply Android application plugin

    // Apply the Google services plugin to enable Firebase
    id("com.google.gms.google-services")  // This is for Firebase services (Google Sign-In, Firebase Analytics, etc.)

    id("kotlin-android")  // Apply Kotlin plugin for Android development
    id("kotlin-kapt")  // Apply Kotlin KAPT plugin for annotation processing
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
    implementation("androidx.annotation:annotation:1.9.1")
    implementation("androidx.appcompat:appcompat:1.7.1")  // AppCompat for backward compatibility
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.9.1")  // Lifecycle components for better lifecycle management
    implementation("androidx.activity:activity-compose:1.7.2")  // Activity Compose for Jetpack Compose support
    implementation("androidx.compose.ui:ui-tooling-preview:1.5.0")  // Preview support for Jetpack Compose  
    implementation("androidx.compose.ui:ui-test-junit4:1.5.0")  // JUnit4 support for testing Jetpack Compose UI
    implementation("androidx.compose.runtime:runtime-livedata:1.5.0")  // LiveData support for Jetpack Compose
    implementation("androidx.navigation:navigation-compose:2.7.0")  // Navigation component for Jetpack Compose
    implementation("androidx.hilt:hilt-work:1.0.0")  // Hilt support for WorkManager
    implementation("androidx.work:work-runtime-ktx:2.8.1")  // WorkManager for background tasks 
    implementation("androidx.security:security-crypto:1.1.0-alpha04")  // Security Crypto for encryption
    implementation("androidx.preference:preference-ktx:1.2.0")  // Preference KTX for easier preference management
    implementation("com.google.dagger:hilt-android:2.44")
    implementation("androidx.legacy:legacy-support-v4:1.0.0")

    implementation("com.google.dagger:hilt-android-testing:2.44")  // Hilt testing support
    implementation("com.google.android.material:material:1.10.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.9.1")  // Material Design components
    kapt("com.google.dagger:hilt-android-compiler:2.44")  // Hilt compiler for annotation processing
    kapt("androidx.hilt:hilt-compiler:1.2.0")  // Hilt compiler for AndroidX


    implementation("com.google.firebase:firebase-analytics-ktx")  // Firebase Analytics with Kotlin extensions

    // Add any other Firebase dependencies you need (like Firestore, Realtime Database, etc.)
}

flutter {
    source = "../.."  // Set the source path for Flutter
}


