package com.aliya.servicespractice.flutter_platform_integration;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
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

import io.flutter.plugin.common.EventChannel;

public class ForegroundService extends Service {
    private int counterValue = 0;
    private String apiResponse = "";
    private String url = "";
    private Handler handler;
    private Runnable runnable;
    private NotificationManager notificationManager;
    int totalServers=0;
    int onlineServers=0;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.e("Service", "Foreground Service Started...");

        // Register the receiver to update URL
        IntentFilter filter = new IntentFilter("com.aliya.SEND_URL");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            registerReceiver(urlUpdateReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
        }

        handler = new Handler();
        runnable = new Runnable() {
            @Override
            public void run() {
//                counterValue++;
//                Log.e("Service", "Counter: " + counterValue);

                // Perform API request
                new Thread(() -> {
                    try {
                        URL apiUrl = new URL(url);  // Use the updated URL
                        HttpURLConnection connection = (HttpURLConnection) apiUrl.openConnection();
                        connection.setRequestMethod("GET");
                        connection.setConnectTimeout(5000);
                        connection.setReadTimeout(5000);
                        int responseCode = connection.getResponseCode();
                        totalServers++;
                        if (responseCode == HttpURLConnection.HTTP_OK) {
                            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                            StringBuilder response = new StringBuilder();
                            String inputLine;
                            while ((inputLine = in.readLine()) != null) {
                                response.append(inputLine);
                            }
                            in.close();
                            onlineServers++;
                            apiResponse = response.toString();
                        } else {
                            apiResponse = "Error: " + responseCode;
                        }
                    } catch (Exception e) {
                        apiResponse = "Exception: " + e.getMessage();
                    }

                    // Send broadcast with updated data
                    Intent broadcastIntent = new Intent("com.aliya.TO_GET_API_DATA");
//                    broadcastIntent.putExtra("counterValue", counterValue);
                    broadcastIntent.putExtra("apiResponse", apiResponse);
                    sendBroadcast(broadcastIntent);
                    updateNotification();
                }).start();

                handler.postDelayed(this, 5000);  // Repeat every 5 seconds
            }
        };
        handler.post(runnable);

        // Start foreground notification
        startForeground(1001, createNotification());
        return START_STICKY;
    }

    private Notification createNotification() {
        String CHANNEL_ID = "ForegroundServiceChannel";
        NotificationChannel channel = null;
        notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            channel = new NotificationChannel(CHANNEL_ID, "Foreground Service", NotificationManager.IMPORTANCE_LOW);
            notificationManager.createNotificationChannel(channel);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return new Notification.Builder(this, CHANNEL_ID)
                    .setContentTitle("Monitoring CHI Servers")
                    .setContentText("Servers are running")
                    .setSmallIcon(R.drawable.companylogo)
                    .build();
        }
        return null;
    }
    private void updateNotification() {
        // Update the notification content
        String updatedContentText = onlineServers + " of " + totalServers +  " Online " ;

        Notification notification = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notification = new Notification.Builder(this, "ForegroundServiceChannel")
                    .setContentTitle("Monitoring CHI Servers")
                    .setContentText(updatedContentText)
                    .setSmallIcon(R.drawable.companylogo)
                    .build();
        }
        // Notify or update the existing notification
        notificationManager.notify(1001, notification);
    }

    // Receive URL updates from MainActivity
    private final BroadcastReceiver urlUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent != null) {
                url = intent.getStringExtra("url");
                Log.e("Service", "Updated URL: " + url);
                totalServers=0;
                onlineServers=0;
            }
        }
    };

    @Override
    public void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(runnable);
        unregisterReceiver(urlUpdateReceiver);
        totalServers=0;
        onlineServers=0;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}

