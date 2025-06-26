buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    project.afterEvaluate {
        // Evita errores si la app está configurando shrinkResources sin minifyEnabled
        if (project.name == "app") {
            project.extensions.configure<com.android.build.gradle.AppExtension>("android") {
                buildTypes.getByName("release").apply {
                    isMinifyEnabled = false
                    isShrinkResources = false // Desactivado para evitar error de compilación
                }
            }
        }
    }

    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
