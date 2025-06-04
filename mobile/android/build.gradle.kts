// Project-level build.gradle.kts
buildscript {
    repositories {
        google()  // Google's Maven repository
        mavenCentral()  // Maven Central repository
    }
    dependencies {
        // Upgraded AGP version
        classpath("com.android.tools.build:gradle:8.10.1")  // AGP version 8.10.1
        // Google services plugin
        classpath("com.google.gms:google-services:4.4.2")  // Add the Google services plugin version
    }
}

allprojects {
    repositories {
        google()  // Google's Maven repository
        mavenCentral()  // Maven Central repository
        maven("https://storage.googleapis.com/download.flutter.io")  // Flutter's Maven repository
    }
}
