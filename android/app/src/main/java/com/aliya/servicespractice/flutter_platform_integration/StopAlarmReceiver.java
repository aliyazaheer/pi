package com.aliya.servicespractice.flutter_platform_integration;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class StopAlarmReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        // Call the stopAlarmSound method to stop the sound
        if (context instanceof ForegroundService) {
            ((ForegroundService) context).stopAlarmSound();
        }
    }
}
