// ===========================
// ROOT BUILD.GRADLE.KTS
// Flutter + Firebase chuẩn
// ===========================

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Firebase Google Services plugin
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// =================================
// FLUTTER CUSTOM BUILD DIRECTORY
// (KHÔNG ĐƯỢC XOÁ ĐOẠN NÀY)
// =================================
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val subDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(subDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
