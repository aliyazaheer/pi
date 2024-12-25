package com.aliya.servicespractice.flutter_platform_integration;

import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

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
