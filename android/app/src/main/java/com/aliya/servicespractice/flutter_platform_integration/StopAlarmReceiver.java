package com.aliya.servicespractice.flutter_platform_integration;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.aliya.servicespractice.flutter_platform_integration.ForegroundService;

public class StopAlarmReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Log.e("StopAlarmReceiver", "Stop Alarm clicked");
        ForegroundService foregroundService = ForegroundService.getInstance();
        if (foregroundService != null) {
            foregroundService.stopAlarmSound();
        }
    }
}
