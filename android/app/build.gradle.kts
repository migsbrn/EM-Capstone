// android/app/build.gradle

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services'

android {
    namespace "com.example.easymind"
    compileSdk 35

    defaultConfig {
        applicationId "com.example.easymind"
        minSdk 23              // Required for Firebase Auth
        targetSdk 35
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            shrinkResources false
            signingConfig signingConfigs.debug
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    // Optional: enable Jetpack Compose if your project uses it
    // buildFeatures {
    //     compose true
    // }
    // composeOptions {
    //     kotlinCompilerExtensionVersion = '1.5.3'
    // }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:33.9.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'

    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.10"
}
