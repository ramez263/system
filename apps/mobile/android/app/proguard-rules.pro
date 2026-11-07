# Keep androidx.startup classes and resources so that
# androidx.startup.AppInitializer can discover initializers at runtime.
# This prevents NoClassDefFoundError: Landroidx/startup/R$string.
-keep class androidx.startup.** { *; }
-keepclassmembers class androidx.startup.R$* { *; }
-keepnames class androidx.startup.R$string { *; }
-keep class androidx.startup.InitializationProvider { *; }
-keep class androidx.startup.AppInitializer { *; }

# Keep Flutter plugin initializers that use androidx.startup.
-keep class androidx.work.** { *; }
-keepnames class androidx.work.R$* { *; }
