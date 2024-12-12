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

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "com.aliya.servicespractice/foreground";
    private static final String EVENT_CHANNEL = "com.aliya.servicespractice/counterStream";
    private int counterValue = 0;
    private String apiResponse = "";
    private String url = "";

    private EventChannel.EventSink eventSink;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Start the ForegroundService
        Intent serviceIntent = new Intent(this, ForegroundService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent);
        } else {
            startService(serviceIntent);
        }

        // Register the receiver for counter updates
        IntentFilter filter = new IntentFilter("com.aliya.TO_GET_API_DATA");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            registerReceiver(dataUpdateReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                registerReceiver(dataUpdateReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
            }
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        // Set up MethodChannel
        // Inside MainActivity
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("sendUrl")) {
                        String url = call.argument("url");
                        if (url != null) {
                            // Send the updated URL to ForegroundService
                            Intent intent = new Intent("com.aliya.SEND_URL");
                            intent.putExtra("url", url);
                            sendBroadcast(intent); // Broadcasting URL update
                            Log.d("ForegroundService", "Sent URL: " + url);
                        } else {
                            result.error("INVALID_ARGUMENT", "URL is null", null);
                        }
                        result.success(null);
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
                counterValue = intent.getIntExtra("counterValue", 0);
                apiResponse = intent.getStringExtra("apiResponse");
                url = intent.getStringExtra("url");

                if (eventSink != null) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("counterValue", counterValue);
                    data.put("apiResponse", apiResponse);
                    data.put("url", url);
                    eventSink.success(data);
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
