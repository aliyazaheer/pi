# Keep all public classes and members
-keep class * {
    public *;
}

# Keep all Flutter classes
-keep class io.flutter.** { *; }

# Keep annotated classes (common in libraries like Retrofit or Gson)
-keepattributes *Annotation*

# Prevent obfuscation of enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

