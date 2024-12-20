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
    private static final String TAG = "ForegroundService";
    private List<String> urls = new ArrayList<>();
    private Handler handler;
    private Runnable runnable;
    private NotificationManager notificationManager;
    private int totalServers = 0;
    private int onlineServers = 0;
    private static List<String> apisResponse = new ArrayList<>();

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
                handler.postDelayed(this, 5000);
            }
        };
        handler.post(runnable);

        // Start foreground notification
        startForeground(1001, createNotification());
        return START_STICKY;
    }

    private void processUrls() {
        new Thread(() -> {
            try {
                apisResponse.clear();
                totalServers = urls.size();
                onlineServers = 0;

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

                            String responseString = response.toString();
                            Log.e(TAG, "Response for " + urlString + ": " + responseString);

                            apisResponse.add(responseString);
                            onlineServers++;
                            Log.e("TAG","++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"  );
                            Log.e("TAG","+++++++++++++++++Online Counter: " + onlineServers);
                            Log.e("TAG","++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"  );
                        } else {
                            Log.e(TAG, "Error code for " + urlString + ": " + responseCode);
                            apisResponse.add("Error: " + responseCode);
                        }
                    } catch (Exception e) {
                        Log.e(TAG, "Error hitting API for " + urlString, e);
                        apisResponse.add("Exception: " + e.getMessage());
                    }
                }

                // Send broadcast with updated data
                Intent broadcastIntent = new Intent("com.aliya.TO_GET_API_DATA");
                broadcastIntent.putStringArrayListExtra("apisResponse", new ArrayList<>(apisResponse));
//                broadcastIntent.putExtra("totalServers", totalServers);
//                broadcastIntent.putExtra("onlineServers", onlineServers);
                sendBroadcast(broadcastIntent);

                Log.e(TAG, "Broadcast sent with responses: " + apisResponse);

                // Update notification with server status
                updateNotification();

            } catch (Exception e) {
                Log.e(TAG, "Overall API processing error", e);
            }
        }).start();
    }

    // Receive URL updates from MainActivity
    private final BroadcastReceiver urlUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent != null && intent.hasExtra("urls")) {
                urls = intent.getStringArrayListExtra("urls");
                if (urls != null) {
                    Log.e(TAG, "Received URLs in Receiver: " + urls);
                    // Trigger immediate processing of new URLs
                    processUrls();
                }
            }
        }
    };
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
        totalServers = 0;
        onlineServers = 0;
        apisResponse.clear();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}



