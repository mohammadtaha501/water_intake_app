
-keep class com.dexterous.flutterlocalnotifications.** { *; }

-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }

-keep class com.dexterous.** { *; }

# Keep Flutter and Kotlin classes
-keep class io.flutter.** { *; }
-keep class kotlin.** { *; }
-dontwarn kotlin.**
-dontwarn com.dexterous.flutterlocalnotifications.**

-keep class com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver$* { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**