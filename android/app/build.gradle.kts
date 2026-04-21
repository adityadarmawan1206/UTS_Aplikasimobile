plugins {
    // 1. Android Application harus yang pertama
    id("com.android.application")
    
    // 2. Kotlin
    id("kotlin-android")
    
    // 3. Flutter Plugin
    id("dev.flutter.flutter-gradle-plugin")
    
    // 4. Google Services (Cukup satu baris ini saja, TANPA 'version' atau 'apply false')
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.5.1")) // Versi stabil terbaru saat ini

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")
}