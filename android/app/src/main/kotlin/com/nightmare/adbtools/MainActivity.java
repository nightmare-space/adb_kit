package com.nightmare.adbtools;


import android.content.Context;
import android.graphics.Bitmap;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private WifiManager.MulticastLock mLock;
    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
    }
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "multicast-lock").setMethodCallHandler((call, result) -> {
            if (call.method.equals("aquire")) {
                Log.i("adb","aquire");
                result.success(aquireMulticastLock());
            } else if (call.method.equals("release")) {
                result.success(releaseMulticastLock());
            } else {
                result.notImplemented();
            }
        });
    }
    protected boolean aquireMulticastLock() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
            return false;
        }

        WifiManager wifi;
        Context context = getApplicationContext();
        wifi = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);

        mLock = wifi.createMulticastLock("discovery-multicast-lock");
        mLock.acquire();
        return true;
    }

    protected boolean releaseMulticastLock() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
            return false;
        }

        mLock.release();
        return true;
    }
}
