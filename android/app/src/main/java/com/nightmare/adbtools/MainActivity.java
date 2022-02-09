package com.nightmare.adbtools;


import static com.nightmare.adbtools.Message.CONNECTING;
import static com.nightmare.adbtools.Message.DEVICE_FOUND;
import static com.nightmare.adbtools.Message.DEVICE_NOT_FOUND;
import static com.nightmare.adbtools.Message.INSTALLING_PROGRESS;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
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
import android.view.WindowManager;
import android.widget.Toast;

import androidx.annotation.NonNull;


import com.nightmare.adbtools.adblib.AdbBase64;
import com.nightmare.adbtools.adblib.AdbConnection;
import com.nightmare.adbtools.adblib.AdbCrypto;
import com.nightmare.adbtools.adblib.AdbStream;
import com.nightmare.adbtools.adblib.UsbChannel;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    static String tag = "Nightmare";
    final String channelName = "adb";
    UsbDevice mDevice;
    private AdbCrypto adbCrypto;
    // 给 Terminal 用的，
    private AdbConnection adbConnection;
    private UsbManager mManager;
    private AdbStream stream;
    // 组播相关的锁
    // 安卓默认关闭组播，因为会耗电，所以用完记得释放
    private WifiManager.MulticastLock mLock;
    MethodChannel channel;

    private void initPlugin(FlutterEngine flutterEngine) {
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), channelName);
        channel.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "write":
                    String data = (String) call.arguments;
                    putCommand(data);
                    break;
                case "exec_cmd":
                    String cmd = (String) call.arguments;
                    new Thread(() -> {
                        execCmmandFromFlutter(cmd, result);
                    }).start();
                    break;
                case "tcpip":
                    int port = (int) call.arguments;
                    String resultData = "";
                    String sendData = "tcpip:" + port;
                    try {
                        AdbStream cmdStream;
                        if (port == 5555) {
                            cmdStream = adbConnection.open(sendData);
                        } else {
                            cmdStream = adbConnection.open("usb:");
                        }
                        while (!cmdStream.isClosed()) {
                            try {
                                resultData = new String(cmdStream.read()).trim();
                                Log.d(Const.TAG, resultData);
                            } catch (IOException e) {
                                // there must be a Stream Close Exception
                                break;
                            }
                        }
                        String finalResultData = resultData;
                        runOnUiThread(() -> {
                            result.success(finalResultData);
                        });
                    } catch (IOException | InterruptedException e) {
                        e.printStackTrace();
                    }
                    break;
                case "push":
                    ArrayList<String> args = (ArrayList<String>) call.arguments;
                    String localPath = args.get(0);
                    File local = new File(localPath);
                    String remotePath = args.get(1) + local.getName();
                    new Thread(() -> {
                        try {
                            new Push(adbConnection, local, remotePath).execute(handler);
                            runOnUiThread(() -> {
                                result.success("ok");
                            });
                        } catch (InterruptedException | IOException e) {
                            e.printStackTrace();
                        }
                    }).start();
                    break;
                case "read":
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

    public synchronized void execCmmandFromFlutter(String cmd, MethodChannel.Result result) {
        Log.d(tag, "execCmmandFromFlutter");
        String resultData = "";
        try {
            AdbStream cmdStream = adbConnection.open("shell:" + cmd);
            while (!cmdStream.isClosed()) {
                try {
                    resultData = new String(cmdStream.read()).trim();
                    Log.d(Const.TAG, resultData);
                } catch (IOException e) {
                    // there must be a Stream Close Exception
                    break;
                }
            }
            String finalResultData = resultData;
            runOnUiThread(() -> {
                result.success(finalResultData);
            });
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }

    private final Handler handler = new AdbMessageHandler(this);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (Build.VERSION.SDK_INT >= 28) {
            WindowManager.LayoutParams lp = getWindow().getAttributes();
            lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            getWindow().setAttributes(lp);
        }
        mManager = (UsbManager) getSystemService(Context.USB_SERVICE);
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
        intentFilter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
        intentFilter.addAction(Message.USB_PERMISSION);
        registerReceiver(mUsbReceiver, intentFilter);

        //Check USB
        UsbDevice device = getIntent().getParcelableExtra(UsbManager.EXTRA_DEVICE);
        if (device != null) {
            // 说明是静态广播启动起来的
            // 用户再收到系统弹窗"是否打开ADB工具"，用户点击了是
            System.out.println("From Intent!");
            asyncRefreshAdbConnection(device);
        } else {
            System.out.println("From onCreate!");
            for (String k : mManager.getDeviceList().keySet()) {
                UsbDevice usbDevice = mManager.getDeviceList().get(k);
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
        initPlugin(flutterEngine);
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
        // 之后如果降低 adb targetversion，这个判断还是需要
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.DONUT) {
            return false;
        }
        mLock.release();
        return true;
    }

    void closeWaiting() {
        // 关闭弹窗
    }

    void waitingDialog() {
        // 展示弹窗
    }

    // app已经在前台了会走这个
    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        Log.d("Nightmare", "From onNewIntent");
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
                        channel.invokeMethod("DeviceDetach", null);
                    } catch (Exception e) {
                        Log.w(Const.TAG, "setAdbInterface(null,null) failed", e);
                    }
                }
            } else if (Message.USB_PERMISSION.equals(action)) {
                Log.d(Const.TAG, "From receiver!");
                UsbDevice usbDevice = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                    //user choose YES for your previously popup window asking for grant perssion for this usb device
                    if (null != usbDevice) {
                        asyncRefreshAdbConnection(usbDevice);
                    }
                } else {
                    //user choose NO for your previously popup window asking for grant perssion for this usb device
                    Toast.makeText(context, String.valueOf("您没有授予权限,我没法使用这个设备喔"), Toast.LENGTH_LONG).show();
                }
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
        Log.d("Nightmare", "setAdbInterface");
        if (adbConnection != null) {
            adbConnection.close();
            adbConnection = null;
            mDevice = null;
        }

        UsbManager mManager = (UsbManager) getSystemService(Context.USB_SERVICE);
        if (device != null && intf != null) {
            UsbDeviceConnection connection = mManager.openDevice(device);
            if (connection != null) {
                if (connection.claimInterface(intf, false)) {

                    handler.sendEmptyMessage(Message.CONNECTING);

                    adbConnection = AdbConnection.create(new UsbChannel(connection, intf), adbCrypto);

                    adbConnection.connect();

                    //TODO: DO NOT DELETE IT, I CAN'T EXPLAIN WHY
//                    adbTerminalConnection.open("shell:exec date");
                    mDevice = device;
                    handler.sendEmptyMessage(Message.DEVICE_FOUND);
                    return true;
                } else {
                    connection.close();
                }
            }
        }

        handler.sendEmptyMessage(Message.DEVICE_NOT_FOUND);

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
        // 取消注册广播
        unregisterReceiver(mUsbReceiver);
        try {
            // 关闭adb连接
            if (adbConnection != null) {
                adbConnection.close();
                adbConnection = null;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    void initCommand() {
        // Open the shell stream of ADB
        try {
            stream = adbConnection.open("shell:");
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
            return;
        }
        runOnUiThread(() -> {
            channel.invokeMethod("output", "OTG已连接\r\n");
        });
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
                if (data == null) {
                    runOnUiThread(() -> {
                        channel.invokeMethod("output", "OTG断开\r\n");
                    });
                    continue;
                }
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

}

class AdbMessageHandler extends Handler {
    MainActivity activity;

    private double currentProgress = 0;

    public AdbMessageHandler(MainActivity activity) {
        this.activity = activity;
    }

    @Override
    public void handleMessage(android.os.Message msg) {
        switch (msg.what) {
            case DEVICE_FOUND:
                activity.closeWaiting();
                activity.channel.invokeMethod("CloseOTGDialog", null);
                activity.initCommand();
                Log.w(MainActivity.tag, activity.mDevice.toString());
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    activity.channel.invokeMethod("DeviceAttach", activity.mDevice.getProductName());
                }
                break;

            case CONNECTING:
                activity.waitingDialog();
                activity.channel.invokeMethod("ShowOTGDialog", null);
                break;

            case DEVICE_NOT_FOUND:
                activity.closeWaiting();
                activity.channel.invokeMethod("CloseOTGDialog", null);
                break;
            case INSTALLING_PROGRESS:
                int step = msg.arg1;
                double progress = (double) msg.obj;

                if (step == Message.PUSH_PART) {
                    currentProgress = progress;
                } else if (step == Message.PM_INST_PART) {
                    currentProgress = 100 * Const.PUSH_PERCENT + (1 - Const.PUSH_PERCENT) * progress;
                }
                Log.d(MainActivity.tag, String.valueOf(currentProgress));
                activity.channel.invokeMethod("Progress", currentProgress);
                break;
        }
    }
}