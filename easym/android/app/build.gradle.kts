plugins {
    id "com.android.application"
    id "kotlin-android"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services" // Correctly added Firebase plugin here
}

android {
    namespace = "com.example.easymind"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString() // Ensuring compatibility with Java 1.8
    }

    defaultConfig {
        applicationId = "com.example.easymind"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

dependencies {
    // Import the Firebase BoM (Bill of Materials) to manage Firebase dependencies.
    implementation platform("com.google.firebase:firebase-bom:33.9.0")

    // Firebase dependencies
    implementation "com.google.firebase:firebase-analytics"  // Example for Firebase Analytics
    implementation "com.google.firebase:firebase-auth"       // Example for Firebase Authentication
    implementation "com.google.firebase:firebase-firestore"  // Example for Firestore
    // Add other Firebase dependencies as required (e.g., Firebase Messaging, Firestore, etc.)
}

apply plugin: 'com.google.gms.google-services'  // Apply the Firebase Google services plugin
