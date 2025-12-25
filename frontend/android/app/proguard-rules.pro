# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dart and Flutter core
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Keep all model classes (for JSON serialization)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep SharedPreferences and related classes
-keep class androidx.preference.** { *; }
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$** { *; }
-keep class com.google.android.gms.common.internal.safeparcel.SafeParcelable { *; }

# Keep shared_preferences plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep all JSON serialization
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep all data classes and models (prevent stripping of fields)
-keepclassmembers class * {
    <fields>;
    <init>(...);
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# HTTP and networking
-keep class java.net.** { *; }
-keep class javax.net.** { *; }
-dontwarn java.net.**
-dontwarn javax.net.**

# Agora RTC Engine
-keep class io.agora.**{*;}

# Socket.IO
-keep class io.socket.** { *; }
-keep class com.github.nkzawa.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# Retrofit (if used)
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Geolocator (Location services)
-keep class com.baseflow.geolocator.** { *; }
-keep class com.baseflow.geocoding.** { *; }

# Audio Players
-keep class xyz.luan.audioplayers.** { *; }

# Audio Recorder
-keep class com.llfbandit.record.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Cached Network Image
-keep class io.flutter.plugins.urllauncher.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }


# Keep Dart VM and essential Flutter classes only
-dontwarn io.flutter.**

# Keep only MainActivity (app entry point)
-keep class com.assurefix.app.MainActivity { *; }

# Keep constructors for reflection (but allow obfuscation)
-keepclassmembers class * {
    public <init>(...);
}

# Optimize: Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Additional rules for debugging (can be removed for production)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
