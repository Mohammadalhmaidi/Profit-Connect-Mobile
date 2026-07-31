# Flutter通用规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Dio
-keep class com.example.dio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**
-dontwarn android.net.http.**

# Keep JSON models (Gson/Jackson serialization)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class * implements java.io.Serializable { *; }

# Keep Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep your data models
-keep class com.example.my_first_app.** { *; }

# Keep kotlin metadata
-keep class kotlin.Metadata { *; }
