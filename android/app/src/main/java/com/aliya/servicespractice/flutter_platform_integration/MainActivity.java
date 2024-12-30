package com.aliya.servicespractice.flutter_platform_integration;

import android.annotation.SuppressLint;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ServiceInfo;
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
    private Integer delayTime; // Use Integer instead of int



    @SuppressLint("NewApi")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        handleAlarmStop();
        // Start the ForegroundService
        if (!isServiceRunning(this, ForegroundService.class)) {
            Intent serviceIntent = new Intent(this, ForegroundService.class);
// Add foreground service type for Android 11 (API 30) and above
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // Set the foreground service type as an extra
                serviceIntent.putExtra("foregroundServiceType",
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);  // Adjust type as needed
            }



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
                            Integer delayTime = call.argument("delayTime");
                            Log.e(TAG, "Starting service with URLs: " + urls + " and delay: " + delayTime);

                            if (urls != null) {
                                Intent serviceIntent = new Intent(this, ForegroundService.class);
                                serviceIntent.putStringArrayListExtra("urls", new ArrayList<>(urls));
                                if (delayTime != null) {
                                    serviceIntent.putExtra("delayTime", delayTime);
                                }

                                // Add foreground service type for Android 11+
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                    serviceIntent.putExtra("foregroundServiceType",
                                            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);
                                }

                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    startForegroundService(serviceIntent);
                                } else {
                                    startService(serviceIntent);
                                }

                                // Short delay to ensure service is started
                                try {
                                    Thread.sleep(100);
                                } catch (InterruptedException e) {
                                    Log.e(TAG, "Sleep interrupted", e);
                                }

                                // Then send URLs via broadcast to ensure they're received
                                Intent urlIntent = new Intent("com.aliya.SEND_URL");
                                urlIntent.putStringArrayListExtra("urls", new ArrayList<>(urls));
                                sendBroadcast(urlIntent);

                                // Also send delay time
                                if (delayTime != null) {
                                    Intent delayIntent = new Intent("com.minutes");
                                    delayIntent.putExtra("delayTime", delayTime);
                                    sendBroadcast(delayIntent);
                                }

                                Log.e(TAG, "Service started and broadcasts sent");
                                result.success(null);
                            } else {
                                result.error("INVALID_ARGUMENT", "URLs are null", null);
                            }
                            break;

                        case "delayTime":
                            // This handles all the delay time changes
                            delayTime = call.argument("delayTime");
                            Intent delayIntent = new Intent("com.minutes");
                            delayIntent.putExtra("delayTime", delayTime);
                            sendBroadcast(delayIntent);
                            result.success("Sent delayTime: " + delayTime);
                            break;

                        case "stopForegroundService":
                            Intent stopIntent = new Intent(this, ForegroundService.class);
                            stopService(stopIntent);
                            result.success("Stopped Foreground Service");
                            break;

                        case "restartForegroundService":
                            // Stop existing service
                            stopService(new Intent(this, ForegroundService.class));
                            try {
                            Thread.sleep(200);
                        } catch (InterruptedException e) {
                            Log.e(TAG, "Sleep interrupted", e);
                        }


                            // Get parameters
                            List<String> newUrls = call.argument("urls");
                            delayTime = call.argument("delayTime");

                            Log.e(TAG, "Restarting service with URLs: " + newUrls);

                            // Start service with both delay time and URLs
                            Intent restartIntent = new Intent(this, ForegroundService.class);
                            if (delayTime != null) {
                                restartIntent.putExtra("delayTime", delayTime);
                            }
                            if (newUrls != null) {
                                restartIntent.putStringArrayListExtra("urls", new ArrayList<>(newUrls));
                            }

                            // Add foreground service type for Android 11+
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                restartIntent.putExtra("foregroundServiceType",
                                        ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);
                            }

                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(restartIntent);
                            } else {
                                startService(restartIntent);
                            }
                            // Small delay to ensure service is started
                            try {
                                Thread.sleep(100);
                            } catch (InterruptedException e) {
                                Log.e(TAG, "Sleep interrupted", e);
                            }


                            // Also send URLs via broadcast to ensure they're received
                            if (newUrls != null) {
                                Intent urlIntent = new Intent("com.aliya.SEND_URL");
                                urlIntent.putStringArrayListExtra("urls", new ArrayList<>(newUrls));
                                sendBroadcast(urlIntent);
                                // Send delay broadcast if present
                                if (delayTime != null) {
                                    delayIntent = new Intent("com.minutes");
                                    delayIntent.putExtra("delayTime", delayTime);
                                    sendBroadcast(delayIntent);
                                }

                                Log.e(TAG, "Broadcast sent with URLs: " + newUrls);
                            }

                            result.success("Service Restarted");
                            break;

                        case "updateServiceUrls":
                            List<String> updatedUrls = call.argument("urls");
                            delayTime = call.argument("delayTime");

                            if (updatedUrls != null && delayTime != null) {
                                // Create intent to update service
                                Intent updateServiceIntent = new Intent(this, ForegroundService.class);
                                updateServiceIntent.putStringArrayListExtra("urls", new ArrayList<>(updatedUrls));
                                updateServiceIntent.putExtra("delayTime", delayTime);

                                // Add foreground service type for Android 11+
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                    updateServiceIntent.putExtra("foregroundServiceType",
                                            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);
                                }

                                stopService(updateServiceIntent);

                                try {
                                    Thread.sleep(200);
                                } catch (InterruptedException e) {
                                    Log.e(TAG, "Sleep interrupted", e);
                                }


                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    startForegroundService(updateServiceIntent);
                                } else {
                                    startService(updateServiceIntent);
                                }
                                // Small delay to ensure service is started
                                try {
                                    Thread.sleep(100);
                                } catch (InterruptedException e) {
                                    Log.e(TAG, "Sleep interrupted", e);
                                }


                                result.success("Service updated with new URLs and delay time");
                            } else {
                                result.error("INVALID_ARGUMENT", "Updated URLs or delay time is null", null);
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
                boolean isOnline = intent.getBooleanExtra("isOnline", true);
                boolean alarmDone = intent.getBooleanExtra("alarmDone", false);


                Log.e(TAG, "Received in MainActivity - Responses: " + apiResponses);

                if (eventSink != null) {
//                    List<String> data=apiResponses;
                    Map<String, Object> data = new HashMap<>();
                    data.put("apisResponse", apiResponses);
                    data.put("totalServers", totalServers);
                    data.put("onlineServers", onlineServers);
                    data.put("isOnline", isOnline);
                    data.put("alarmDone", alarmDone);

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

