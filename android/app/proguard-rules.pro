# flutter_local_notifications: Gson memuat cache jadwal saat cancel() — R8 menghapus generic TypeToken.
# Lihat: IllegalStateException TypeToken harus dibuat dengan type argument

-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes *Annotation*

-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }

-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ThreadPool / ScheduledExecutor callback (plugin)
-dontwarn com.dexterous.flutterlocalnotifications.**
