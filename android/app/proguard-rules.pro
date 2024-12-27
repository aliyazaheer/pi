# Keep your foreground service class
-keep class com.yourpackage.YourForegroundService { *; }

# If you're using any specific libraries for your service
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.app.NotificationManager { *; }