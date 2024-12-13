package com.aliya.servicespractice.flutter_platform_integration;

import android.annotation.SuppressLint;
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

    @SuppressLint("NewApi")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Start the ForegroundService
        Intent serviceIntent = new Intent(this, ForegroundService.class);
        startService(serviceIntent);

        // Register the receiver for API data updates
        IntentFilter filter = new IntentFilter("com.aliya.TO_GET_API_DATA");
        registerReceiver(dataUpdateReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        // Set up MethodChannel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("sendUrls")) {
                        List<String> urls = call.argument("urls");
                        Log.e(TAG, "Got URLs in MainActivity: " + urls);

                        if (urls != null) {
                            // Send the updated URLs to ForegroundService
                            Intent intent = new Intent("com.aliya.SEND_URL");
                            intent.putStringArrayListExtra("urls", new ArrayList<>(urls));
                            sendBroadcast(intent);
                            Log.e(TAG, "Broadcast sent with URLs: " + urls);
                            result.success(null);
                        } else {
                            result.error("INVALID_ARGUMENT", "URLs are null", null);
                        }
                    } else {
                        result.notImplemented();
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
                    List<String> data=apiResponses;
//                    Map<String, Object> data = new HashMap<>();
//                    data.put("apisResponse", apiResponses);
//                    data.put("totalServers", totalServers);
//                    data.put("onlineServers", onlineServers);
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
}











//package com.aliya.servicespractice.flutter_platform_integration;
//
//import android.annotation.SuppressLint;
//import android.content.BroadcastReceiver;
//import android.content.Context;
//import android.content.Intent;
//import android.content.IntentFilter;
//import android.os.Build;
//import android.os.Bundle;
//import android.util.Log;
//
//import androidx.annotation.NonNull;
//
//import io.flutter.embedding.android.FlutterActivity;
//import io.flutter.embedding.engine.FlutterEngine;
//import io.flutter.plugin.common.EventChannel;
//import io.flutter.plugin.common.MethodChannel;
//import io.flutter.plugins.GeneratedPluginRegistrant;
//
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//
//public class MainActivity extends FlutterActivity {
//    private static final String METHOD_CHANNEL = "com.aliya.servicespractice/foreground";
//    private static final String EVENT_CHANNEL = "com.aliya.servicespractice/counterStream";
//    private int counterValue = 0;
//    private String apiResponse = "";
//    private String url = "";
//
//    private EventChannel.EventSink eventSink;
//
//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//
//        // Start the ForegroundService
//        Intent serviceIntent = new Intent(this, ForegroundService.class);
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            startForegroundService(serviceIntent);
//        } else {
//            startService(serviceIntent);
//        }
//
//        // Register the receiver for counter updates
//        IntentFilter filter = new IntentFilter("com.aliya.TO_GET_API_DATA");
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            registerReceiver(dataUpdateReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
//        } else {
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                registerReceiver(dataUpdateReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
//            }
//        }
//    }
//
//    @Override
//    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//        super.configureFlutterEngine(flutterEngine);
//        GeneratedPluginRegistrant.registerWith(flutterEngine);
//
//        // Set up MethodChannel
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
//                .setMethodCallHandler((call, result) -> {
//                    if (call.method.equals("sendUrls")) {
//                        // Correctly handle the list of URLs
//                        List<String> urls = call.argument("urls");
//                        Log.e("ForegroundService", "got URLs in main activity: " + urls);
//
//                        if (urls != null) {
//                            // Send the updated URLs to ForegroundService
//                            Intent intent = new Intent("com.aliya.SEND_URL");
//                            intent.putStringArrayListExtra("urls", new ArrayList<>(urls));
//                            sendBroadcast(intent);
//                            Log.e("ForegroundService", "Sent URLs: " + urls);
//                            result.success(null);
//                        } else {
//                            result.error("INVALID_ARGUMENT", "URLs are null", null);
//                        }
//                    } else if (call.method.equals("getData")) {
//                        // Implement method to get data from service
//                        List<String> apiResponses = getApiResponses(); // You'll need to implement this
//                        result.success(apiResponses);
//                    } else {
//                        result.notImplemented();
//                    }
//                });
//
//        // Set up EventChannel (similar to before)
//        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL)
//                .setStreamHandler(new EventChannel.StreamHandler() {
//                    @Override
//                    public void onListen(Object arguments, EventChannel.EventSink events) {
//                        eventSink = events;
//                    }
//
//                    @Override
//                    public void onCancel(Object arguments) {
//                        eventSink = null;
//                    }
//                });
//    }
//
//    // Helper method to get API responses (you'll need to implement the logic)
//    private List<String> getApiResponses() {
//        // Retrieve stored API responses from your service or shared preferences
//        // This is a placeholder - you'll need to implement actual response storage
//        List<String> responses = new ArrayList<>();
//        // Add your logic to retrieve responses
//        return responses;
//    }
//
//    // BroadcastReceiver to handle updates from ForegroundService
////    private final BroadcastReceiver dataUpdateReceiver = new BroadcastReceiver() {
////        @Override
////        public void onReceive(Context context, Intent intent) {
////            if (intent != null) {
//////                counterValue = intent.getIntExtra("counterValue", 0);
////                apiResponse = intent.getStringExtra("apiResponse");
////                url = intent.getStringExtra("url");
////
////                if (eventSink != null) {
////                    Map<String, Object> data = new HashMap<>();
////                    data.put("counterValue", counterValue);
////                    data.put("apiResponse", apiResponse);
////                    data.put("url", url);
////                    eventSink.success(data);
////                }
////            }
////        }
////    };
//    private final BroadcastReceiver dataUpdateReceiver = new BroadcastReceiver() {
//        @Override
//        public void onReceive(Context context, Intent intent) {
//            if (intent != null) {
//                List<String> apiResponses = intent.getStringArrayListExtra("apisResponse");
//                int totalServers = intent.getIntExtra("totalServers", 0);
//                int onlineServers = intent.getIntExtra("onlineServers", 0);
//
//                if (eventSink != null) {
//                    Map<String, Object> data = new HashMap<>();
//                    data.put("apisResponse", apiResponses);
//                    data.put("totalServers", totalServers);
//                    data.put("onlineServers", onlineServers);
//                    eventSink.success(data);
//                }
//            }
//        }
//    };
//
//
//    @Override
//    protected void onDestroy() {
//        super.onDestroy();
//        unregisterReceiver(dataUpdateReceiver);
//    }
//}
