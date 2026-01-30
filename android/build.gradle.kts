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
    val subproject = this
    // Set build directory for the subproject
    subproject.layout.buildDirectory.value(newBuildDir.dir(subproject.name))
    
    val configureNamespace = {
        // Inject namespace for AGP 8.0+ compatibility if android extension exists
        if (subproject.hasProperty("android")) {
            val android = subproject.extensions.findByName("android")
            if (android != null) {
                // Force NDK version to avoid compatibility issues with NDK 27
                try {
                    val setNdkVersion = android.javaClass.getMethod("setNdkVersion", String::class.java)
                    setNdkVersion.invoke(android, "26.1.10909125")
                } catch (e: Exception) {
                    // Ignore if method not found
                }

                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    
                    // If namespace is not set, provide a default based on group or project name
                    if (getNamespace.invoke(android) == null) {
                        val packageName = subproject.group.toString().takeIf { it.isNotEmpty() }
                            ?: "com.example.ominious.${subproject.name.replace("-", "_")}"
                        setNamespace.invoke(android, packageName)
                    }
                } catch (e: Exception) {
                    // Ignore if reflection fails or namespace is already handled
                }
            }
        }
    }

    if (subproject.state.executed) {
        configureNamespace()
    } else {
        subproject.afterEvaluate {
            configureNamespace()
        }
    }

    // Standard Flutter dependency management
    if (subproject.name != "app") {
        subproject.evaluationDependsOn(":app")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
