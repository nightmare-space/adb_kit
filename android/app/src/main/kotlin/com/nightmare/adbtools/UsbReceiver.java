package com.nightmare.adbtools;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class UsbReceiver extends BroadcastReceiver {
    public UsbReceiver() {
    }

    public void onReceive(Context context, Intent intent) {
        String action;
        if (intent != null && (action = intent.getAction()) != null && action.equals("android.hardware.usb.action.USB_DEVICE_ATTACHED")) {
            Intent intent2 = new Intent("htetznaing.usb.permission");
            intent2.putExtra("device", (Bundle) intent.getParcelableExtra("device"));
            Log.d("UsbReceiver", "Broadcasting USB_CONNECTED");
            context.sendBroadcast(intent2);
        }
    }
}
