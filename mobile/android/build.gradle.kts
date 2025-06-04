allprojects {
    repositories {
        google()  // Google repository for Firebase
        mavenCentral()  // Maven Central repository for other dependencies
    }
}

// Define custom build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Set the build directory for subprojects
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Clean task to remove build directories
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
