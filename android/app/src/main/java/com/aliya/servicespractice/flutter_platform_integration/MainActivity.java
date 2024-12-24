package com.aliya.servicespractice.flutter_platform_integration;

import android.annotation.SuppressLint;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

// Add these imports
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";
    private static final String METHOD_CHANNEL = "com.aliya.servicespractice/foreground";
    private static final String EVENT_CHANNEL = "com.aliya.servicespractice/counterStream";
    private EventChannel.EventSink eventSink;
    static final int ERROR_NOTIFICATION_ID = 1001;


    @SuppressLint("NewApi")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handleAlarmStop();
        // Start the ForegroundService
        if (!isServiceRunning(this, ForegroundService.class)) {
            Intent serviceIntent = new Intent(this, ForegroundService.class);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent);
            } else {
                startService(serviceIntent);
            }
        }


        // Register the receiver for API data updates
        IntentFilter filter = new IntentFilter("com.aliya.TO_GET_API_DATA");
        registerReceiver(dataUpdateReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleAlarmStop();
    }

    private void handleAlarmStop() {
        if (getIntent().getBooleanExtra("stopAlarm", false)) {
            ForegroundService.getInstance().stopAlarmSound();
        }
    }

    private boolean isServiceRunning(Context context, Class<?> serviceClass) {
        android.app.ActivityManager manager =
                (android.app.ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (android.app.ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "startForegroundService":
                            List<String> urls = call.argument("urls");
                            Log.e(TAG, "Got URLs in MainActivity: " + urls);

                            if (urls != null) {
                                Intent intent = new Intent("com.aliya.SEND_URL");
                                intent.putStringArrayListExtra("urls", new ArrayList<>(urls));
                                sendBroadcast(intent);
                                Log.e(TAG, "Broadcast sent with URLs: " + urls);
                                result.success(null);
                            } else {
                                result.error("INVALID_ARGUMENT", "URLs are null", null);
                            }
                            break;

                        case "delayTime":
                            // This handles all the delay time changes
                            int delayTime = call.argument("delayTime");
                            Intent intent = new Intent("com.minutes");
                            intent.putExtra("delayTime", delayTime);
                            sendBroadcast(intent);
                            result.success("Sent delayTime: " + delayTime);
                            break;

                        case "stopForegroundService":
                            Intent stopIntent = new Intent(this, ForegroundService.class);
                            stopService(stopIntent);
                            result.success("Stopped Foreground Service");
                            break;

                        case "restartForegroundService":
                            // First ensure the service is stopped
                            stopService(new Intent(this, ForegroundService.class));

                            // Start the service again
                            Intent serviceIntent = new Intent(this, ForegroundService.class);
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(serviceIntent);
                            } else {
                                startService(serviceIntent);
                            }

                            // Handle URLs if provided
                            List<String> newUrls = call.argument("urls");
                            if (newUrls != null) {
                                Intent urlIntent = new Intent("com.aliya.SEND_URL");
                                urlIntent.putStringArrayListExtra("urls", new ArrayList<>(newUrls));
                                sendBroadcast(urlIntent);
                            }
                            result.success("Service Restarted");
                            break;
                        case "updateServiceUrls":
                            List<String> updatedUrls = call.argument("urls");
                            if (updatedUrls != null) {
                                // Send updated URLs to service
                                Intent updateIntent = new Intent("com.aliya.SEND_URL");
                                updateIntent.putStringArrayListExtra("urls", new ArrayList<>(updatedUrls));
                                sendBroadcast(updateIntent);

                                // Force service to process new URLs immediately
                                Intent refreshIntent = new Intent("com.aliya.REFRESH_SERVICE");
                                sendBroadcast(refreshIntent);

                                result.success("URLs updated");
                            } else {
                                result.error("INVALID_ARGUMENT", "Updated URLs are null", null);
                            }
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                });

        // Set up EventChannel
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink = null;
                    }
                });
    }

    // BroadcastReceiver to handle updates from ForegroundService
    private final BroadcastReceiver dataUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent != null) {
                List<String> apiResponses = intent.getStringArrayListExtra("apisResponse");
                int totalServers = intent.getIntExtra("totalServers", 0);
                int onlineServers = intent.getIntExtra("onlineServers", 0);

                Log.e(TAG, "Received in MainActivity - Responses: " + apiResponses);

                if (eventSink != null) {
//                    List<String> data=apiResponses;
                    Map<String, Object> data = new HashMap<>();
                    data.put("apisResponse", apiResponses);
                    data.put("totalServers", totalServers);
                    data.put("onlineServers", onlineServers);
                    eventSink.success(data);
                    Log.e(TAG, "Sent to EventSink: " + data);
                }
            }
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(dataUpdateReceiver);

    }

    @Override
    protected void onResume() {
        super.onResume();
        ForegroundService service = ForegroundService.getInstance();
        if (service != null) {
            service.stopAlarmSound();
            NotificationManager notificationManager =
                    (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.cancel(ForegroundService.ERROR_NOTIFICATION_ID);
        }
    }
}

