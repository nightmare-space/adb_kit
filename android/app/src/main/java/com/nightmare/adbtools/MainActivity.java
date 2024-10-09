package com.nightmare.adbtools;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    static public String tag = "Nightmare";
    final String channelName = "adb";
    // 组播相关的锁
    // 安卓默认关闭组播，因为会耗电，所以用完记得释放
    private WifiManager.MulticastLock mLock;
    MethodChannel channel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (Build.VERSION.SDK_INT >= 28) {
            WindowManager.LayoutParams lp = getWindow().getAttributes();
            // 适配刘海屏
            lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            getWindow().setAttributes(lp);
        }
        Intent serviceIntent = new Intent();
        serviceIntent.setComponent(new ComponentName("com.nightmare.sharespace", "com.nightmare.sharespace.YourService"));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            startForegroundService(serviceIntent);
        else
            startService(serviceIntent);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "multicast-lock").setMethodCallHandler((call, result) -> {
            if (call.method.equals("aquire")) {
                Log.i("adb", "aquire");
                result.success(aquireMulticastLock());
            } else if (call.method.equals("release")) {
                result.success(releaseMulticastLock());
            } else {
                result.notImplemented();
            }
        });
    }

    // 申请组播锁
    protected boolean aquireMulticastLock() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
            return false;
        }
        WifiManager wifi;
        Context context = getApplicationContext();
        wifi = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        mLock = wifi.createMulticastLock("discovery-multicast-lock");
        mLock.setReferenceCounted(true);
        mLock.acquire();
        return true;
    }

    protected boolean releaseMulticastLock() {
        mLock.release();
        return true;
    }

    // app已经在前台了会走这个
    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        Log.d("Nightmare", "From onNewIntent");
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}