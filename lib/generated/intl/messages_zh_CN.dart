// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
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
  String get localeName => 'zh_CN';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("关于软件"),
        "ac": MessageLookupByLibrary.simpleMessage("已自动连接"),
        "adbStarting": MessageLookupByLibrary.simpleMessage("ADB启动中..."),
        "agreement": MessageLookupByLibrary.simpleMessage("隐私政策"),
        "alreadyConnectDevice":
            MessageLookupByLibrary.simpleMessage("已成功连接的设备"),
        "appManager": MessageLookupByLibrary.simpleMessage("应用管理"),
        "appName": MessageLookupByLibrary.simpleMessage("ADB KIT"),
        "autoConnectDevice": MessageLookupByLibrary.simpleMessage("自动发现并连接设备"),
        "autoFit": MessageLookupByLibrary.simpleMessage("自适应"),
        "branch": MessageLookupByLibrary.simpleMessage("版本分支"),
        "changeLog": MessageLookupByLibrary.simpleMessage("更新日志"),
        "chooseInstallPath": MessageLookupByLibrary.simpleMessage("选择安装路径"),
        "commonServiceStartup": MessageLookupByLibrary.simpleMessage("常用服务启动"),
        "confirm": MessageLookupByLibrary.simpleMessage("确认"),
        "connect": MessageLookupByLibrary.simpleMessage("连接"),
        "connectMethod": MessageLookupByLibrary.simpleMessage("连接方法"),
        "connectMethodDes1":
            MessageLookupByLibrary.simpleMessage("1.设备与PC处于于一个局域网"),
        "connectMethodDes2":
            MessageLookupByLibrary.simpleMessage("2.打开PC的终端模拟器，执行连接"),
        "connectMethodDes3":
            MessageLookupByLibrary.simpleMessage("3.执行adb devices查看设备列表是有新增"),
        "connectMethodTip": MessageLookupByLibrary.simpleMessage(
            "该功能需要ROOT！！！并且是给本机打开的！！！给对方设备打开无线调试在主页点击已经连接的设备后面的箭头进到的二级页"),
        "copy": MessageLookupByLibrary.simpleMessage("复制"),
        "copyed": MessageLookupByLibrary.simpleMessage("已复制"),
        "customFileSelecter": MessageLookupByLibrary.simpleMessage("自定义文件选择器"),
        "dark": MessageLookupByLibrary.simpleMessage("暗黑"),
        "dashboard": MessageLookupByLibrary.simpleMessage("控制面板"),
        "debugPaintLayerBordersEnabled":
            MessageLookupByLibrary.simpleMessage("显示层级边界"),
        "debugPaintPointersEnabled":
            MessageLookupByLibrary.simpleMessage("突出点击对象"),
        "debugPaintSizeEnabled":
            MessageLookupByLibrary.simpleMessage("显示文字基准线"),
        "debugRepaintRainbowEnabled":
            MessageLookupByLibrary.simpleMessage("显示刷新区域"),
        "debugShowMaterialGrid": MessageLookupByLibrary.simpleMessage("显示绘制网格"),
        "deleteHistoryTip":
            MessageLookupByLibrary.simpleMessage("左右滑动对应的历史可以删除"),
        "desktop": MessageLookupByLibrary.simpleMessage("桌面"),
        "devTools": MessageLookupByLibrary.simpleMessage("开发者工具"),
        "developerSettings": MessageLookupByLibrary.simpleMessage("开发者设置"),
        "deviceInfo": MessageLookupByLibrary.simpleMessage("设备信息"),
        "deviceNotConnect": MessageLookupByLibrary.simpleMessage("设备未正常连接"),
        "disconnect": MessageLookupByLibrary.simpleMessage("断开连接"),
        "fileSelecterType": MessageLookupByLibrary.simpleMessage("文件选择器类型"),
        "fileSelecterTypeDes":
            MessageLookupByLibrary.simpleMessage("选择系统文件方式可以不用申请完整储存权限"),
        "fixDeviceWithoutDataLocalPermission":
            MessageLookupByLibrary.simpleMessage(
                "适配部分设备没有 \n/data/local/tmp 的权限问题"),
        "historyConnect": MessageLookupByLibrary.simpleMessage("历史连接"),
        "home": MessageLookupByLibrary.simpleMessage("主页"),
        "iceBox": MessageLookupByLibrary.simpleMessage("冰箱"),
        "inputDeviceAddress":
            MessageLookupByLibrary.simpleMessage("输入对方设备IP连接"),
        "inputFormat":
            MessageLookupByLibrary.simpleMessage("输入格式为“IP地址:端口号 配对码”"),
        "inputPassword": MessageLookupByLibrary.simpleMessage("输入密码"),
        "inputPasswordTip":
            MessageLookupByLibrary.simpleMessage("部分设备需要密码才能连接(车机)"),
        "installApkFailed": MessageLookupByLibrary.simpleMessage("安装失败"),
        "installDes1": MessageLookupByLibrary.simpleMessage(
            "建议选择 /system/xbin ,因为安卓自带程序大部分都在 system/bin ,装在前者更方便管理个人安装的一些可执行程序。"),
        "installDes2": MessageLookupByLibrary.simpleMessage("该功能暂未适配动态分区"),
        "installDes3": MessageLookupByLibrary.simpleMessage("该功能需要ROOT权限"),
        "installToSystem": MessageLookupByLibrary.simpleMessage("安装到系统"),
        "ip": MessageLookupByLibrary.simpleMessage("IP地址"),
        "ipIsEmtpy": MessageLookupByLibrary.simpleMessage("IP地址不能为空"),
        "joinQQGT": MessageLookupByLibrary.simpleMessage("第一时间获得更新动态，联系开发者"),
        "joinSocial": MessageLookupByLibrary.simpleMessage("加入社交群"),
        "keyCopyF": MessageLookupByLibrary.simpleMessage("未发现adb key"),
        "keyCopyS": MessageLookupByLibrary.simpleMessage("已复制"),
        "language": MessageLookupByLibrary.simpleMessage("语言"),
        "layout": MessageLookupByLibrary.simpleMessage("布局风格"),
        "light": MessageLookupByLibrary.simpleMessage("浅色"),
        "localAddress": MessageLookupByLibrary.simpleMessage("本机IP"),
        "log": MessageLookupByLibrary.simpleMessage("日志"),
        "needAuth": MessageLookupByLibrary.simpleMessage("需要授权，请注意设备上的弹窗"),
        "netDebugOpenFail": MessageLookupByLibrary.simpleMessage("请检查Root权限"),
        "networkDebug": MessageLookupByLibrary.simpleMessage("网络调试"),
        "noDeviceConnect": MessageLookupByLibrary.simpleMessage("未连接任何设备"),
        "noHistoryTip":
            MessageLookupByLibrary.simpleMessage("这里就像开发者的钱包一样，什么也没有"),
        "openLocalNetDebug": MessageLookupByLibrary.simpleMessage("打开网络ADB调试"),
        "openQQFail": MessageLookupByLibrary.simpleMessage("唤起QQ失败，请检查是否安装"),
        "other": MessageLookupByLibrary.simpleMessage("其他"),
        "pad": MessageLookupByLibrary.simpleMessage("平板"),
        "pair": MessageLookupByLibrary.simpleMessage("配对"),
        "pairMode": MessageLookupByLibrary.simpleMessage("配对模式"),
        "pairSuccess":
            MessageLookupByLibrary.simpleMessage("配对成功，请删除配对码，修改连接端口，连接设备"),
        "pairTip": MessageLookupByLibrary.simpleMessage(
            "只支持Android11及以上版本，在系统无线调试页面扫码配对"),
        "phone": MessageLookupByLibrary.simpleMessage("手机"),
        "port": MessageLookupByLibrary.simpleMessage("端口号"),
        "primaryColor": MessageLookupByLibrary.simpleMessage("产品色"),
        "processManager": MessageLookupByLibrary.simpleMessage("进程管理"),
        "qqChannel": MessageLookupByLibrary.simpleMessage("QQ频道"),
        "qqGroup": MessageLookupByLibrary.simpleMessage("QQ群"),
        "rebootServer": MessageLookupByLibrary.simpleMessage("重启服务"),
        "reconnect": MessageLookupByLibrary.simpleMessage("重新连接"),
        "releaseToAction": MessageLookupByLibrary.simpleMessage("释放以执行操作"),
        "scanQRCodeDes": MessageLookupByLibrary.simpleMessage(
            "点击可放大二维码\n二维码支持ADB KIT、无界、以及任意浏览器扫描\n也支持浏览器直接打开二维码对应IP进行连接"),
        "scanToConnect": MessageLookupByLibrary.simpleMessage("扫码连接"),
        "serverPath": MessageLookupByLibrary.simpleMessage("服务端路径"),
        "setting": MessageLookupByLibrary.simpleMessage("设置"),
        "settings": MessageLookupByLibrary.simpleMessage("设置"),
        "showPerformanceOverlay":
            MessageLookupByLibrary.simpleMessage("打开性能监控"),
        "showSemanticsDebugger": MessageLookupByLibrary.simpleMessage("显示组件语义"),
        "showStatusBar": MessageLookupByLibrary.simpleMessage("显示状态栏"),
        "slogan": MessageLookupByLibrary.simpleMessage("道阻且长、行则将至"),
        "start": MessageLookupByLibrary.simpleMessage("启动"),
        "startServer": MessageLookupByLibrary.simpleMessage("启动服务"),
        "stopServer": MessageLookupByLibrary.simpleMessage("停止服务"),
        "successSCM": MessageLookupByLibrary.simpleMessage("已经成功发送连接消息"),
        "switchTheme": MessageLookupByLibrary.simpleMessage("切换主题"),
        "system": MessageLookupByLibrary.simpleMessage("系统"),
        "systemFileSelecter": MessageLookupByLibrary.simpleMessage("系统文件选择器"),
        "taskManager": MessageLookupByLibrary.simpleMessage("任务管理"),
        "terminal": MessageLookupByLibrary.simpleMessage("终端模拟器"),
        "terms": MessageLookupByLibrary.simpleMessage("服务条款"),
        "theme": MessageLookupByLibrary.simpleMessage("主题"),
        "udpCF": MessageLookupByLibrary.simpleMessage("通过UDP发现自动连接设备失败"),
        "uncaughtDE": MessageLookupByLibrary.simpleMessage("未捕捉到的Dart异常"),
        "uncaughtUE": MessageLookupByLibrary.simpleMessage("未捕捉到的UI构建异常"),
        "view": MessageLookupByLibrary.simpleMessage("界面")
      };
}
