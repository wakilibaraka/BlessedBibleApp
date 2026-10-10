import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.baraka.bibleapp"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    androidResources {
        noCompress.add("db")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.baraka.bibleapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Fail the build if a bundled database is a Git LFS pointer (or otherwise
// not SQLite). Without this, a clone made without `git lfs pull` builds a
// "working" APK that opens to empty Bible text.
val verifyContentAssets by tasks.registering {
    val root = file("../..")
    doLast {
        val magic = "SQLite format 3\u0000".toByteArray(Charsets.US_ASCII)
        val packs = File(root, "assets/packs")
            .listFiles { f -> f.name.endsWith(".db") }?.toList() ?: emptyList()
        for (f in listOf(File(root, "assets/bible/bible.db")) + packs) {
            val head = ByteArray(16)
            val n = if (f.exists()) f.inputStream().use { it.read(head) } else -1
            if (n < 16 || !head.contentEquals(magic)) {
                throw GradleException(
                    "${f.path} is not a SQLite database (Git LFS pointer?). " +
                        "Run: git lfs install && git lfs pull"
                )
            }
        }
    }
}
tasks.matching { it.name == "preBuild" }.configureEach {
    dependsOn(verifyContentAssets)
}
