// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")

    // ✅ Google Services plugin for Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.rhemn.lifecare_connect"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Optional: Use only if you're relying on NDK features

    defaultConfig {
        applicationId = "com.rhemn.lifecare_connect"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // ✅ Required for large apps using many methods (e.g., Firebase)
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ For Java 8+ APIs on lower API levels
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("release") {
            // ⚠️ Replace debug signing with a real keystore for production builds
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase Bill of Materials - synchronizes Firebase dependency versions
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))

    // ✅ Firebase SDKs
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-appcheck")
    implementation("com.google.firebase:firebase-messaging")

    // ✅ Kotlin and AndroidX dependencies
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.10")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.appcompat:appcompat:1.6.1")

    // ✅ Java 8+ desugaring support for backward compatibility
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
