# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.firebase.crashlytics.** { *; }

# Dio
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Kotlin
-keepattributes Signature
-keepattributes *Annotation*
-keep class kotlin.** { *; }

# Gson/Serialization
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# R8
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Flutter engine
-keep class io.flutter.embedding.engine.FlutterJNI { *; }

# Keep plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }