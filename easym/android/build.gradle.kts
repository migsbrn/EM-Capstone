plugins {
    // Add the dependency for the Google services Gradle plugin at the project level
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()       // Ensure Google Maven repository is included
        mavenCentral() // Include Maven Central repository
    }
}

rootProject.buildDir = "../build"  // Set the build directory at the root level

subprojects {
    // Ensure each subproject uses the root build directory
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}

subprojects {
    // Ensures the ":app" project is evaluated before any subproject
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete) {
    // Clean task to delete the root build directory
    delete rootProject.buildDir
}
