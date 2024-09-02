// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(name) => "Installing ${name}...";

  static String m1(name) => "Uploading ${name}...";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "ac": MessageLookupByLibrary.simpleMessage("Auto Connect"),
        "agreement": MessageLookupByLibrary.simpleMessage("Agreement"),
        "alreadyConnectDevice":
            MessageLookupByLibrary.simpleMessage("Already Connect Devices"),
        "appManager": MessageLookupByLibrary.simpleMessage("App Manager"),
        "appName": MessageLookupByLibrary.simpleMessage("ADB KIT"),
        "autoConnectDevice":
            MessageLookupByLibrary.simpleMessage("Auto connect device in LAN"),
        "autoFit": MessageLookupByLibrary.simpleMessage("Responsive"),
        "branch": MessageLookupByLibrary.simpleMessage("Branch"),
        "changeLog": MessageLookupByLibrary.simpleMessage("Change Log"),
        "chooseInstallPath":
            MessageLookupByLibrary.simpleMessage("Choose install path"),
        "commonServiceStartup":
            MessageLookupByLibrary.simpleMessage("Common service startup"),
        "commonSwitch": MessageLookupByLibrary.simpleMessage("Commont Switch"),
        "connectMethod": MessageLookupByLibrary.simpleMessage("Connect Method"),
        "connectMethodDes1": MessageLookupByLibrary.simpleMessage(
            "1.Device and computer on the same LAN"),
        "connectMethodDes2": MessageLookupByLibrary.simpleMessage(
            "2.Open terminal on computer,exec connect"),
        "connectMethodDes3": MessageLookupByLibrary.simpleMessage(
            "3.Exec \'adb devices\' to check if any devices connected"),
        "connectMethodTip": MessageLookupByLibrary.simpleMessage(
            "This function need ROOT!!!and it work locally,help the other devices enable ADB debug,go the home page tap the list of devces to enable"),
        "copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "copyed": MessageLookupByLibrary.simpleMessage("Copyed"),
        "currentDebug": MessageLookupByLibrary.simpleMessage("Current"),
        "currentVersion":
            MessageLookupByLibrary.simpleMessage("Current Version"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "debugPaintLayerBordersEnabled": MessageLookupByLibrary.simpleMessage(
            "Debug Paint Layer Borders Enabled"),
        "debugPaintPointersEnabled": MessageLookupByLibrary.simpleMessage(
            "Debug Paint Pointers Enabled"),
        "debugPaintSizeEnabled":
            MessageLookupByLibrary.simpleMessage("Debug Paint Size Enabled"),
        "debugRepaintRainbowEnabled":
            MessageLookupByLibrary.simpleMessage("Show Repaint Rainbow"),
        "debugShowMaterialGrid":
            MessageLookupByLibrary.simpleMessage("Debug Show Material Grid"),
        "deleteHistoryTip": MessageLookupByLibrary.simpleMessage(
            "Swipe left or right to delete the corresponding history"),
        "desktop": MessageLookupByLibrary.simpleMessage("Desktop"),
        "devTools": MessageLookupByLibrary.simpleMessage("DevTools"),
        "developerSettings":
            MessageLookupByLibrary.simpleMessage("Developer Settings"),
        "deviceInfo": MessageLookupByLibrary.simpleMessage("Device Info"),
        "deviceNotConnect":
            MessageLookupByLibrary.simpleMessage("Device not connect"),
        "disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
        "displayScreenPointer":
            MessageLookupByLibrary.simpleMessage("Display screen pointer"),
        "displayTouch":
            MessageLookupByLibrary.simpleMessage("Display Touch Feedback"),
        "dropTip": MessageLookupByLibrary.simpleMessage("Drop file here or"),
        "fixDeviceWithoutDataLocalPermission":
            MessageLookupByLibrary.simpleMessage(
                "fix some device without \n/data/local/tmp permission"),
        "historyConnect":
            MessageLookupByLibrary.simpleMessage("History Connect"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "iceBox": MessageLookupByLibrary.simpleMessage("IceBox"),
        "inputDeviceAddress": MessageLookupByLibrary.simpleMessage(
            "Input Device Address To Connect"),
        "inputFormat": MessageLookupByLibrary.simpleMessage(
            "Input format is \"IP:PORT CODE\""),
        "installApk": MessageLookupByLibrary.simpleMessage("Install Apk"),
        "installApkFailed":
            MessageLookupByLibrary.simpleMessage("Install failed"),
        "installDes1": MessageLookupByLibrary.simpleMessage(
            "You can choose \'/system/xbin\',because most of binary in \'/system/bin\'"),
        "installDes2": MessageLookupByLibrary.simpleMessage(
            "This function can not support dynamic partition"),
        "installDes3":
            MessageLookupByLibrary.simpleMessage("This function need ROOT"),
        "installToSystem":
            MessageLookupByLibrary.simpleMessage("Install to System"),
        "installingApk": m0,
        "joinQQGT": MessageLookupByLibrary.simpleMessage(
            "Get the latest updates and contact the developer"),
        "joinQQGroup": MessageLookupByLibrary.simpleMessage("Join QQ Group"),
        "keyCopyF": MessageLookupByLibrary.simpleMessage("No adb key found"),
        "keyCopyS": MessageLookupByLibrary.simpleMessage("Copied"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "layout": MessageLookupByLibrary.simpleMessage("Layout Style"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "localAddress": MessageLookupByLibrary.simpleMessage("Local Address"),
        "log": MessageLookupByLibrary.simpleMessage("Log"),
        "netDebugOpenFail": MessageLookupByLibrary.simpleMessage(
            "Please check root permission"),
        "networkDebug": MessageLookupByLibrary.simpleMessage("LAN debug"),
        "noDeviceConnect": MessageLookupByLibrary.simpleMessage("No Devices"),
        "noHistoryTip": MessageLookupByLibrary.simpleMessage(
            "It\'s like a developer\'s wallet. Nothing"),
        "openLocalNetDebug": MessageLookupByLibrary.simpleMessage(
            "Enable Network ADB Debug Mode"),
        "openQQFail": MessageLookupByLibrary.simpleMessage(
            "Open QQ fail,please check if installed"),
        "openSourceLicense":
            MessageLookupByLibrary.simpleMessage("Open Source License"),
        "other": MessageLookupByLibrary.simpleMessage("Other"),
        "otherVersionDownload":
            MessageLookupByLibrary.simpleMessage("Download Other Version"),
        "pad": MessageLookupByLibrary.simpleMessage("Pad"),
        "phone": MessageLookupByLibrary.simpleMessage("Phone"),
        "primaryColor": MessageLookupByLibrary.simpleMessage("Primary Color"),
        "processManager":
            MessageLookupByLibrary.simpleMessage("Process Manager"),
        "pushTips":
            MessageLookupByLibrary.simpleMessage("Tap button to select file"),
        "rebootServer": MessageLookupByLibrary.simpleMessage("Reboot Server"),
        "reconnect": MessageLookupByLibrary.simpleMessage("Reconnect"),
        "releaseToAction":
            MessageLookupByLibrary.simpleMessage("Release to action"),
        "remoteAdbDebug":
            MessageLookupByLibrary.simpleMessage("Remote Adb Debug"),
        "remoteDebuSwitchgDes":
            MessageLookupByLibrary.simpleMessage("Without Root"),
        "remoteDebugDes": MessageLookupByLibrary.simpleMessage("Remote"),
        "scanQRCodeDes": MessageLookupByLibrary.simpleMessage(
            "Tap to scale QR code,only in the same LAN can scan\nQR code support scan with broswer/ADBTool\nalso can open url by broswer"),
        "scanToConnect":
            MessageLookupByLibrary.simpleMessage("Scan QR Code To Connect"),
        "screenshot": MessageLookupByLibrary.simpleMessage("Screenshots"),
        "serverPath": MessageLookupByLibrary.simpleMessage("Server Path"),
        "setting": MessageLookupByLibrary.simpleMessage("Setting"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "showLayoutboundary":
            MessageLookupByLibrary.simpleMessage("Show Layoutboundary"),
        "showPerformanceOverlay":
            MessageLookupByLibrary.simpleMessage("Show Performance Overlay"),
        "showSemanticsDebugger":
            MessageLookupByLibrary.simpleMessage("Show Semantics Debugger"),
        "showStatusBar": MessageLookupByLibrary.simpleMessage("Show Statusbar"),
        "slogan": MessageLookupByLibrary.simpleMessage("I\'ll try my best"),
        "start": MessageLookupByLibrary.simpleMessage("Start"),
        "startServer": MessageLookupByLibrary.simpleMessage("Start Server"),
        "stopServer": MessageLookupByLibrary.simpleMessage("Stop Server"),
        "successSCM": MessageLookupByLibrary.simpleMessage(
            "Connect Message Send Success"),
        "switchTheme": MessageLookupByLibrary.simpleMessage("Switch Theme"),
        "taskManager": MessageLookupByLibrary.simpleMessage("Task Manager"),
        "terminal": MessageLookupByLibrary.simpleMessage("Terminal"),
        "terms": MessageLookupByLibrary.simpleMessage("Terms"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "udpCF": MessageLookupByLibrary.simpleMessage("Connect By UDP Faild"),
        "uncaughtDE":
            MessageLookupByLibrary.simpleMessage("Uncaught Dart Exception"),
        "uncaughtUE":
            MessageLookupByLibrary.simpleMessage("Uncaught UI Exception"),
        "uploadFile": MessageLookupByLibrary.simpleMessage("Upload File"),
        "uploadingFile": m1,
        "view": MessageLookupByLibrary.simpleMessage("View")
      };
}
