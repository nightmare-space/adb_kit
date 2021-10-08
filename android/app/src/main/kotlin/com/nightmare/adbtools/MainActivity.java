package com.nightmare.adbtools;


import static com.nightmare.adbtools.Message.CONNECTING;
import static com.nightmare.adbtools.Message.DEVICE_FOUND;
import static com.nightmare.adbtools.Message.DEVICE_NOT_FOUND;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbInterface;
import android.hardware.usb.UsbManager;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.cgutman.adblib.AdbBase64;
import com.cgutman.adblib.AdbConnection;
import com.cgutman.adblib.AdbCrypto;
import com.cgutman.adblib.AdbStream;
import com.cgutman.adblib.UsbChannel;
import com.nightmare.adbtools.UI.SpinnerDialog;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private Handler handler;
    private UsbDevice mDevice;
    private AdbCrypto adbCrypto;
    private AdbConnection adbConnection;
    private UsbManager mManager;
    private String user = null;
    private boolean doubleBackToExitPressedOnce = false;
    private AdbStream stream;
    private SpinnerDialog waitingDialog;
    // 组播相关的锁
    // 安卓默认关闭组播，因为会耗电，所以用完记得释放
    private WifiManager.MulticastLock mLock;
    MethodChannel channel;

    private void initPlugin(FlutterEngine flutterEngine) {
        Log.d("nightmare", "init plugin");
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "scrcpy");
        channel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "write":
                    String data = (String) call.arguments;
                    putCommand(data);
                    break;
                case "read":
                    // Print each thing we read from the shell stream
                    Log.d("Nightmare", "Print each thing we read from the shell stream");
                    runOnUiThread(() -> {
                        try {
                            result.success(new String(stream.read()));
                        } catch (InterruptedException | IOException e) {
                            e.printStackTrace();
                        }
                    });
                    break;
                default:
                    break;
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mManager = (UsbManager) getSystemService(Context.USB_SERVICE);

        handler = new Handler() {
            @Override
            public void handleMessage(android.os.Message msg) {
                switch (msg.what) {
                    case DEVICE_FOUND:
                        closeWaiting();
                        initCommand();
                        showKeyboard();
                        break;

                    case CONNECTING:
                        waitingDialog();
                        closeKeyboard();
                        break;

                    case DEVICE_NOT_FOUND:
                        closeWaiting();
                        closeKeyboard();
                        break;
                }
            }
        };

        AdbBase64 base64 = new MyAdbBase64();
        try {
            adbCrypto = AdbCrypto.loadAdbKeyPair(base64, new File(getFilesDir(), "private_key"), new File(getFilesDir(), "public_key"));
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (adbCrypto == null) {
            try {
                adbCrypto = AdbCrypto.generateAdbKeyPair(base64);
                adbCrypto.saveAdbKeyPair(new File(getFilesDir(), "private_key"), new File(getFilesDir(), "public_key"));
            } catch (Exception e) {
                Log.w(Const.TAG, "fail to generate and save key-pair", e);
            }
        }

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("android.hardware.usb.action.USB_DEVICE_DETACHED");
        intentFilter.addAction("htetznaing.usb.permission");
        registerReceiver(mUsbReceiver, intentFilter);

        //Check USB
        UsbDevice device = getIntent().getParcelableExtra(UsbManager.EXTRA_DEVICE);
        if (device != null) {
            System.out.println("From Intent!");
            asyncRefreshAdbConnection(device);
        } else {
            System.out.println("From onCreate!");
            for (String k : mManager.getDeviceList().keySet()) {
                UsbDevice usbDevice = mManager.getDeviceList().get(k);
                handler.sendEmptyMessage(CONNECTING);
                if (mManager.hasPermission(usbDevice)) {
                    asyncRefreshAdbConnection(usbDevice);
                } else {
                    mManager.requestPermission(usbDevice, PendingIntent.getBroadcast(getApplicationContext(), 0, new Intent(Message.USB_PERMISSION), 0));
                }
            }
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
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
        initPlugin(flutterEngine);
    }

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
        // 之后如果降低 adb targetversion，这个判断还是需要
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
            return false;
        }
        mLock.release();
        return true;
    }

    private void closeWaiting() {
        if (waitingDialog != null)
            waitingDialog.dismiss();
    }

    private void waitingDialog() {
        closeWaiting();
        waitingDialog = SpinnerDialog.displayDialog(this, "IMPORTANT ⚡",
                "You may need to accept a prompt on the target device if you are connecting " +
                        "to it for the first time from this device.", false);
    }


    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        System.out.println("From onNewIntent");
        asyncRefreshAdbConnection((UsbDevice) intent.getParcelableExtra(UsbManager.EXTRA_DEVICE));
    }

    public void asyncRefreshAdbConnection(final UsbDevice device) {
        if (device != null) {
            new Thread() {
                @Override
                public void run() {
                    // 找到UsbDevice对应的UsbInterface
                    final UsbInterface intf = findAdbInterface(device);
                    try {
                        setAdbInterface(device, intf);
                    } catch (Exception e) {
                        Log.w(Const.TAG, "setAdbInterface(device, intf) fail", e);
                    }
                }
            }.start();
        }
    }

    BroadcastReceiver mUsbReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            Log.d(Const.TAG, "mUsbReceiver onReceive => " + action);
            if (UsbManager.ACTION_USB_DEVICE_DETACHED.equals(action)) {
                UsbDevice device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                String deviceName = device.getDeviceName();
                if (mDevice != null && mDevice.getDeviceName().equals(deviceName)) {
                    try {
                        Log.d(Const.TAG, "setAdbInterface(null, null)");
                        setAdbInterface(null, null);
                    } catch (Exception e) {
                        Log.w(Const.TAG, "setAdbInterface(null,null) failed", e);
                    }
                }
            } else if (Message.USB_PERMISSION.equals(action)) {
                System.out.println("From receiver!");
                UsbDevice usbDevice = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                handler.sendEmptyMessage(CONNECTING);
                if (mManager.hasPermission(usbDevice))
                    asyncRefreshAdbConnection(usbDevice);
                else
                    mManager.requestPermission(usbDevice, PendingIntent.getBroadcast(getApplicationContext(), 0, new Intent(Message.USB_PERMISSION), 0));
            }
        }
    };

    // searches for an adb interface on the given USB device
    private UsbInterface findAdbInterface(UsbDevice device) {
        int count = device.getInterfaceCount();
        for (int i = 0; i < count; i++) {
            UsbInterface intf = device.getInterface(i);
            if (intf.getInterfaceClass() == 255 && intf.getInterfaceSubclass() == 66 &&
                    intf.getInterfaceProtocol() == 1) {
                return intf;
            }
        }
        return null;
    }

    // Sets the current USB device and interface
    private synchronized boolean setAdbInterface(UsbDevice device, UsbInterface intf) throws IOException, InterruptedException {
        if (adbConnection != null) {
            adbConnection.close();
            adbConnection = null;
            mDevice = null;
        }

        if (device != null && intf != null) {
            UsbDeviceConnection connection = mManager.openDevice(device);
            if (connection != null) {
                if (connection.claimInterface(intf, false)) {
                    handler.sendEmptyMessage(CONNECTING);
                    adbConnection = AdbConnection.create(new UsbChannel(connection, intf), adbCrypto);
                    adbConnection.connect();
                    //TODO: DO NOT DELETE IT, I CAN'T EXPLAIN WHY
                    adbConnection.open("shell:exec date");

                    mDevice = device;
                    handler.sendEmptyMessage(DEVICE_FOUND);
                    return true;
                } else {
                    connection.close();
                }
            }
        }

        handler.sendEmptyMessage(DEVICE_NOT_FOUND);

        mDevice = null;
        return false;
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        unregisterReceiver(mUsbReceiver);
        try {
            if (adbConnection != null) {
                adbConnection.close();
                adbConnection = null;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    private void initCommand() {
        // Open the shell stream of ADB
        try {
            stream = adbConnection.open("shell:");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return;
        } catch (IOException e) {
            e.printStackTrace();
            return;
        } catch (InterruptedException e) {
            e.printStackTrace();
            return;
        }

        // Start the receiving thread
        new Thread(() -> {
            while (!stream.isClosed()) {
                // Print each thing we read from the shell stream
                String data = null;
                try {
                    data = new String(stream.read());
                } catch (InterruptedException | IOException e) {
                    e.printStackTrace();
                }
                Log.d("Nightmare", "data -> " + data);
                String finalData = data;
                runOnUiThread(() -> {
                    channel.invokeMethod("output", finalData);
                });
            }
        }).start();
    }

    private void putCommand(String cmd) {
        // We become the sending thread
        try {
            stream.write((cmd).getBytes(StandardCharsets.UTF_8));
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }

    public void showKeyboard() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
    }

    public void closeKeyboard() {
        View view = this.getCurrentFocus();
        if (view != null) {
            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
        }
    }

    @Override
    public void onBackPressed() {
        if (doubleBackToExitPressedOnce) {
            super.onBackPressed();
            return;
        }

        this.doubleBackToExitPressedOnce = true;
        Toast.makeText(this, "Please click BACK again to exit", Toast.LENGTH_SHORT).show();

        new Handler().postDelayed(new Runnable() {

            @Override
            public void run() {
                doubleBackToExitPressedOnce = false;
            }
        }, 2000);
    }

    private void test() {
        File local = new File(Environment.getExternalStorageDirectory() + "/adm.apk");
        String remotePath = "/sdcard/" + local.getName();
        try {
            new Push(adbConnection, local, remotePath).execute(handler);
            new Install(adbConnection, remotePath, local.length() / 1024).execute(handler);
        } catch (Exception e) {
            Log.w(Const.TAG, "exception caught", e);
        }
    }
}
