# ==============================================================================
# Ramez Tunnel Plus — Production ProGuard & R8 Configuration
# ==============================================================================

# 1. AndroidX Startup & WorkManager
-keep class androidx.startup.** { *; }
-keepclassmembers class androidx.startup.R$* { *; }
-keepnames class androidx.startup.R$string { *; }
-keep class androidx.startup.InitializationProvider { *; }
-keep class androidx.startup.AppInitializer { *; }
-keep class androidx.work.** { *; }
-keepnames class androidx.work.R$* { *; }

# 2. Flutter Embedding & Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 3. Native VPN Engines, Bridge & Pigeon Generated Classes
-keep class com.ramez.tunnel_plus.vpn.** { *; }
-keepclassmembers class com.ramez.tunnel_plus.vpn.** { *; }
-keep class com.ramez.tunnel_plus.vpn.bridge.** { *; }
-keepclassmembers class com.ramez.tunnel_plus.vpn.bridge.** { *; }
-keep class com.ramez.tunnel_plus.vpn.engine.** { *; }
-keep class com.ramez.tunnel_plus.vpn.service.** { *; }
-keep class com.ramez.tunnel_plus.vpn.tile.** { *; }

# 4. Kotlin Coroutines & Standard Library
-keep class kotlinx.coroutines.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlinx.coroutines.**

# 5. Desugared JDK Libs & Crypto
-keep class j$.** { *; }
-dontwarn j$.**
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# 6. Optimization & Stripping
-repackageclasses 'com.ramez.tunnel_plus.obf'
-allowaccessmodification
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
}
