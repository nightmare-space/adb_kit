package com.nightmare.adbtools;


import static com.nightmare.adbtools.Message.USB_PERMISSION;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

public class UsbReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
//        if (intent.getAction().equals("android.hardware.usb.action.USB_STATE")) {
//            if (intent.getExtras().getBoolean("connected")) {
//                // usb 插入
//                Log.d("Nightmare","in");
//                Toast.makeText(context, "插入", Toast.LENGTH_LONG).show();
//            } else {
//                //   usb 拔出
//                Log.d("Nightmare","out");
//                Toast.makeText(context, "拔出", Toast.LENGTH_LONG).show();
//            }
//        }
//        String action;
//        if (intent!=null && (action = intent.getAction()) !=null && action.equals(UsbManager.ACTION_USB_DEVICE_ATTACHED)){
//            Intent intent1 = new Intent();
//            UsbDevice device = (UsbDevice) intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
//            intent1.putExtra(UsbManager.EXTRA_DEVICE, device);
//            Log.d("UsbReceiver","Broadcasting USB_CONNECTED");
//            context.sendBroadcast(intent1);
//        }
    }
}
