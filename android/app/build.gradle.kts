plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Linhas adicionadas
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.plumoapp.plumo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.plumoapp.plumo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    flavorDimensions.add("default")
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Plumo Dev")
        }
        create("prod") {
            dimension = "default"
            resValue("string", "app_name", "Plumo")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Importa a "Lista de Materiais" (BOM) do Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))

    // Adiciona as dependências que queremos (Analytics e Crashlytics)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-crashlytics")
}
