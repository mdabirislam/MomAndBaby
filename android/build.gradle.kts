allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Provider<Directory> = rootProject.layout.dir(provider { File("C:/flutter_builds/pregnancy_care") })
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Provider<Directory> = newBuildDir.map { it.dir(project.name) }
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
