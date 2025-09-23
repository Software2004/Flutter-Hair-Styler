# Keep Flutter and plugin entry points
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Firebase Auth/Core (used in this app)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Handle optional Play Core (deferred components) referenced by Flutter
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Keep Kotlin metadata
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**

# Keep classes with annotations used by reflection
-keepattributes *Annotation*

# Optional: Strip debug logs
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}
