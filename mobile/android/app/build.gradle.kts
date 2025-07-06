import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("kotlin-kapt")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ndkVersion = "27.0.12077973"
    namespace = "com.example.anga"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"  // ✅ Required for Kotlin 2.0+ compatibility with Android tools
    }

    defaultConfig {
        applicationId = "com.example.anga"
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// ✅ Suppress old Java warnings
tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:-options")
}

// ✅ Explicitly set JVM target for all Kotlin compile tasks
tasks.withType<KotlinCompile>().configureEach {
    kotlinOptions.jvmTarget = "11"
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-auth-ktx")

    implementation("androidx.annotation:annotation:1.9.1")
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.9.1")
    implementation("androidx.activity:activity-compose:1.10.1")
    implementation("androidx.compose.ui:ui-tooling-preview:1.8.2")
    implementation("androidx.compose.ui:ui-test-junit4:1.8.2")
    implementation("androidx.compose.runtime:runtime-livedata:1.8.2")
    implementation("androidx.navigation:navigation-compose:2.9.0")
    implementation("androidx.hilt:hilt-work:1.2.0")
    implementation("androidx.work:work-runtime-ktx:2.10.1")
    implementation("androidx.security:security-crypto:1.1.0-beta01")
    implementation("androidx.preference:preference-ktx:1.2.1")
    implementation("com.google.dagger:hilt-android:2.49")
    implementation("androidx.legacy:legacy-support-v4:1.0.0")
    implementation("com.google.dagger:hilt-android-testing:2.44")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.9.1")

    kapt("com.google.dagger:hilt-android-compiler:2.44")
    kapt("androidx.hilt:hilt-compiler:1.2.0")
}

flutter {
    source = "../.."
}
