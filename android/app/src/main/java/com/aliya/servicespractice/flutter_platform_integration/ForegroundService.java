package com.aliya.servicespractice.flutter_platform_integration;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioAttributes;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import io.flutter.plugin.common.EventChannel;



public class ForegroundService extends Service {
    static final int ERROR_NOTIFICATION_ID = 1001;
    private static final String TAG = "ForegroundService";
    private List<String> urls = new ArrayList<>();
    private Handler handler;
    private Runnable runnable;
    private NotificationManager notificationManager;
    private int totalServers = 0;
    private int onlineServers = 0;
    private static List<String> apisResponse = new ArrayList<>();
    private static final String ERROR_CHANNEL_ID = "ServerErrorChannel";
//    private static final int ERROR_NOTIFICATION_ID = 1002;
    private boolean isErrorNotificationShowing = false;
    private MediaPlayer mediaPlayer;
    private static ForegroundService instance;
    private boolean firstTimeAlarmDuringDown;
    private int delayTime = 5000;

    @SuppressLint("NewApi")
    public void onCreate() {
        super.onCreate();
        instance = this;


        // Register receivers
        IntentFilter urlFilter = new IntentFilter("com.aliya.SEND_URL");
        IntentFilter delayFilter = new IntentFilter("com.minutes");

        registerReceiver(urlUpdateReceiver, urlFilter, Context.RECEIVER_NOT_EXPORTED);
        registerReceiver(delayUpdateReceiver, delayFilter, Context.RECEIVER_NOT_EXPORTED);
    }
    private final BroadcastReceiver delayUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if ("com.minutes".equals(intent.getAction()) && intent.hasExtra("delayTime")) {
                int newDelayTime = intent.getIntExtra("delayTime", 5000);
                updateDelayTime(newDelayTime);
                Log.e(TAG, "Delay time updated and rescheduled: " + newDelayTime);
            }
        }
    };

    // Method to handle delay time updates
    private void updateDelayTime(int newDelayTime) {
        delayTime = newDelayTime;

        // Remove any pending callbacks
        if (handler != null && runnable != null) {
            handler.removeCallbacks(runnable);
        }

        // Reschedule with new delay time
        if (runnable != null) {
            handler.postDelayed(runnable, delayTime);
            Log.e(TAG, "Rescheduled runnable with new delay: " + delayTime);
        }
    }

    public static ForegroundService getInstance() {
        return instance;
    }


    @SuppressLint("NewApi")
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.e(TAG, "Foreground Service Started...");

        // Register the receiver to update URL
        IntentFilter filter = new IntentFilter("com.aliya.SEND_URL");
        registerReceiver(urlUpdateReceiver, filter, Context.RECEIVER_NOT_EXPORTED);

        handler = new Handler();
        runnable = new Runnable() {
            @Override
            public void run() {
                Log.e(TAG, "Runnable executing, URLs: " + urls);
                if (urls != null && !urls.isEmpty()) {
                    processUrls();
                } else {
                    Log.e(TAG, "No URLs available to process");
                }
                handler.postDelayed(this, delayTime);
            }
        };
        handler.post(runnable);

        // Start foreground notification
        startForeground(1001, createNotification());

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel errorChannel = new NotificationChannel(
                    ERROR_CHANNEL_ID,
                    "Server Error Notifications",
                    NotificationManager.IMPORTANCE_HIGH
            );

            // Get high-intensity alarm sound
            //for Android 8.0+
            Uri alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM);
            if (alarmSound == null) {
                alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
            }

            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build();

            errorChannel.setSound(alarmSound, audioAttributes);
            errorChannel.enableVibration(true);
            errorChannel.setVibrationPattern(new long[]{1000, 1000, 1000, 1000, 1000});
            errorChannel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

            notificationManager.createNotificationChannel(errorChannel);
        }

        return START_STICKY;
    }


    // Receive URL updates from MainActivity
    private final BroadcastReceiver urlUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent != null) {
                String action = intent.getAction();
                if ("com.aliya.SEND_URL".equals(action) && intent.hasExtra("urls")) {
                    urls = intent.getStringArrayListExtra("urls");
                    Log.e(TAG, "Received updated URLs in Service: " + urls);

                    // Update counts immediately
                    totalServers = urls.size();
                    onlineServers = 0; // Reset online count before new processing

                    // Update notification immediately with new total
                    updateNotification();

                    // Then process URLs
                    processUrls();

                    Log.e(TAG, "Updated counts - Total: " + totalServers + ", Online: " + onlineServers);
                }
                if ("com.minutes".equals(action) && intent.hasExtra("delayTime")) {
                    delayTime = intent.getIntExtra("delayTime", 5000); // Default to 5000 if not set
                    Log.e(TAG, "Updated delayTime to: " + delayTime);
                }

            }
        }
    };
    public class StopAlarmReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            ForegroundService service = ForegroundService.getInstance();
            if (service != null) {
                service.stopAlarmSound(); // Stop the alarm sound
            }

            // Clear the notification
            NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (notificationManager != null) {
                notificationManager.cancel(ForegroundService.ERROR_NOTIFICATION_ID);
            }
        }
    }


    private void processUrls() {
        new Thread(() -> {
            try {
                apisResponse.clear();
//                totalServers = urls.size();
                onlineServers = 0;
                boolean hasError = false;



                Log.e(TAG, "Processing URLs: " + urls);

                for (String urlString : urls) {
                    try {
                        URL apiUrl = new URL(urlString);
                        HttpURLConnection connection = (HttpURLConnection) apiUrl.openConnection();
                        connection.setRequestMethod("GET");
                        connection.setConnectTimeout(5000);
                        connection.setReadTimeout(5000);
                        connection.setRequestProperty("Content-Type", "application/json");

                        int responseCode = connection.getResponseCode();
                        Log.e(TAG, "Response Code for " + urlString + ": " + responseCode);

                        if (responseCode == HttpURLConnection.HTTP_OK) {
                            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                            StringBuilder response = new StringBuilder();
                            String inputLine;
                            while ((inputLine = in.readLine()) != null) {
                                response.append(inputLine);
                            }
                            in.close();
                            firstTimeAlarmDuringDown=false;

                            String responseString = response.toString();
                            Log.e(TAG, "Response for " + urlString + ": " + responseString);

                            apisResponse.add(responseString);
                            onlineServers++;
//                            updateNotification();
                            Log.e("TAG","++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"  );
                            Log.e("TAG","+++++++++++++++++Online Counter: " + onlineServers);
                            Log.e("TAG","++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"  );
                        } else {
                            hasError = true;
                            Log.e(TAG, "Error code for " + urlString + ": " + responseCode);
                            apisResponse.add("Error: " + responseCode);
                        }
                    } catch (Exception e) {
                        hasError = true;
                        Log.e(TAG, "Error hitting API for " + urlString, e);
                        apisResponse.add("Exception: " + e.getMessage());
                    }
                }


                // Send broadcast with updated data
                Intent broadcastIntent = new Intent("com.aliya.TO_GET_API_DATA");
                broadcastIntent.putStringArrayListExtra("apisResponse", new ArrayList<>(apisResponse));
                if(onlineServers>totalServers){
                    onlineServers=totalServers;
                }
                broadcastIntent.putExtra("totalServers", totalServers);
                broadcastIntent.putExtra("onlineServers", onlineServers);
                sendBroadcast(broadcastIntent);

                Log.e(TAG, "Broadcast sent with responses: " + apisResponse);

                // Update notification with server status
                updateNotification();
                if (hasError && !firstTimeAlarmDuringDown) {
                    showErrorNotification();
                } else {
                    removeErrorNotification();
                }
            } catch (Exception e) {
                Log.e(TAG, "Overall API processing error", e);
                updateNotification();
            }
        }).start();
    }

    private void checkGoogleAndNotify() {
        new Thread(() -> {
            try {
                URL googleUrl = new URL("https://www.google.com");
                HttpURLConnection connection = (HttpURLConnection) googleUrl.openConnection();
                connection.setRequestMethod("GET");
                connection.setConnectTimeout(5000);
                connection.setReadTimeout(5000);

                int responseCode = connection.getResponseCode();
                if (responseCode == HttpURLConnection.HTTP_OK) {
                    // Google is accessible, show error notification
                    showErrorNotification();
                } else {
                    Log.e(TAG, "Both servers and Google are inaccessible. Possible network issue.");
                }
            } catch (Exception e) {
                Log.e(TAG, "Error checking Google availability", e);
            }
        }).start();
    }

    private void showErrorNotification() {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, notificationIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        @SuppressLint({"NewApi", "LocalSuppress"}) Notification notification = new Notification.Builder(this, ERROR_CHANNEL_ID)
                .setContentTitle("Server Error")
                .setContentText("One or more servers are not responding")
                .setSmallIcon(R.drawable.companylogo)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .build();

        notificationManager.notify(ERROR_NOTIFICATION_ID, notification);
        playAlarmSound();
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        stopAlarmSound();
        super.onTaskRemoved(rootIntent);
    }

    private void playAlarmSound() {
        Uri alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM);
        if (alarmSound == null) {
            alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
        }

        if (mediaPlayer != null) {
            mediaPlayer.release();
        }

        mediaPlayer = MediaPlayer.create(getApplicationContext(), alarmSound);
        if (mediaPlayer != null) {
            mediaPlayer.setLooping(true);
            mediaPlayer.start();
        }
    }
    public void stopAlarmSound() {
        if (mediaPlayer != null) {
            if (mediaPlayer.isPlaying()) {
                mediaPlayer.stop();
            }
            mediaPlayer.release();
            mediaPlayer = null;
        }
        firstTimeAlarmDuringDown=true;
        // Don't cancel notification here
    }

    private void removeErrorNotification() {
        if (isErrorNotificationShowing) {
            notificationManager.cancel(ERROR_NOTIFICATION_ID);
            isErrorNotificationShowing = false;
        }
    }

    private Notification createNotification() {
        String CHANNEL_ID = "ForegroundServiceChannel";
        NotificationChannel channel = null;
        notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            channel = new NotificationChannel(CHANNEL_ID, "Foreground Service", NotificationManager.IMPORTANCE_LOW);
            notificationManager.createNotificationChannel(channel);
        }

        Intent notificationIntent=new Intent(this, MainActivity.class);
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pendingIntent=PendingIntent.getActivity(this,0,notificationIntent,PendingIntent.FLAG_IMMUTABLE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return new Notification.Builder(this, CHANNEL_ID)
                    .setContentTitle("Monitoring CHI Servers")
                    .setContentText("Initializing server monitoring...")
                    .setSmallIcon(R.drawable.companylogo)
                    .setContentIntent(pendingIntent)
                    .build();
        }
        return null;
    }

    private void updateNotification() {
        if (notificationManager == null) return;

        String updatedContentText = onlineServers + " of " + totalServers + " Online";

        Intent notificationIntent=new Intent(this, MainActivity.class);
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pendingIntent=PendingIntent.getActivity(this,0,notificationIntent,PendingIntent.FLAG_IMMUTABLE);

        Notification notification = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notification = new Notification.Builder(this, "ForegroundServiceChannel")
                    .setContentTitle("Monitoring CHI Servers")
                    .setContentText(updatedContentText)
                    .setSmallIcon(R.drawable.companylogo)
                    .setContentIntent(pendingIntent)
                    .build();

            notificationManager.notify(1001, notification);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (handler != null) {
            handler.removeCallbacks(runnable);
        }
        if (urlUpdateReceiver != null) {
            unregisterReceiver(urlUpdateReceiver);
        }
        unregisterReceiver(new StopAlarmReceiver());
        try {
            unregisterReceiver(urlUpdateReceiver);
            unregisterReceiver(delayUpdateReceiver);
        } catch (IllegalArgumentException e) {
            Log.e(TAG, "Receiver not registered", e);
        }

        urls.clear();
        totalServers = 0;
        onlineServers = 0;
        apisResponse.clear();
        removeErrorNotification();

        // Update notification one final time before destroying
        updateNotification();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}

