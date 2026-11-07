plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.playvortex.vortex"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.playvortex.vortex"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "0.9.6"
        
        ndk {
            abiFilters.add("arm64-v8a")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isDebuggable = true
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    // Minimal - only Kotlin stdlib
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.20")
}
