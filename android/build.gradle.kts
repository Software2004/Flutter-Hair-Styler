allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

/*
subprojects {
    afterEvaluate {
        // Align compileSdk/minSdk/targetSdk across all Android library modules
        extensions.findByName("android")?.let { ext ->
            val versionCatalog = mapOf(
                "compile" to 34,
                "min" to 21,
                "target" to 34
            )
            try {
                val method = ext.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                method.invoke(ext, versionCatalog["compile"])
            } catch (_: Throwable) { }
            try {
                val defaultConfig = ext.javaClass.getMethod("getDefaultConfig").invoke(ext)
                val setMin = defaultConfig.javaClass.getMethod("setMinSdkVersion", Int::class.javaPrimitiveType)
                setMin.invoke(defaultConfig, versionCatalog["min"])
                val setTarget = defaultConfig.javaClass.getMethod("setTargetSdkVersion", Int::class.javaPrimitiveType)
                setTarget.invoke(defaultConfig, versionCatalog["target"])
            } catch (_: Throwable) { }
        }
    }
}
*/
