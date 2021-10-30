# ADB工具

![release](https://img.shields.io/github/v/release/nightmare-space/adb_tool) 
[![Last Commits](https://img.shields.io/github/last-commit/nightmare-space/adb_tool?logo=git&logoColor=white)](https://github.com/nightmare-space/adb_tool/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/nightmare-space/adb_tool?logo=github&logoColor=white)](https://github.com/nightmare-space/adb_tool/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/nightmare-space/adb_tool?logo=github&logoColor=white)](https://github.com/nightmare-space/adb_tool)
[![License](https://img.shields.io/github/license/nightmare-space/adb_tool?logo=open-source-initiative&logoColor=green)](https://github.com/nightmare-space/adb_tool/blob/master/LICENSE)
 ![Platform](https://img.shields.io/badge/support%20platform-android%20%7C%20web%20%7C%20windows%20%7C%20macos%20%7C%20linux-green) ![download time](https://img.shields.io/github/downloads/nightmare-space/adb_tool/total) ![open issues](https://img.shields.io/github/issues/nightmare-space/adb_tool) ![fork](https://img.shields.io/github/forks/nightmare-space/adb_tool?style=social) ![code line](https://img.shields.io/tokei/lines/github/nightmare-space/adb_tool) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/f969750dc4aa424ead664219ddcf321d)](https://app.codacy.com/gh/nightmare-space/adb_tool?utm_source=github.com&utm_medium=referral&utm_content=nightmare-space/adb_tool&utm_campaign=Badge_Grade)

adb 这个简单的可执行文件其实远比我们想象中的强大，adb shell命令在android设备上能获取的权限也非常高，一些需要动态申请的权限adb shell都能直接获取到。
但 adb 始终作为命令行工具，我们无法快捷的使用各部分功能，这也是这个ADB客户端工具存在的意义。
不仅是在PC上，在安卓也能支持ADB设备，支持Android、Windows、macOS、Linux，在各个平台统一操作与UI，提供更方便的ADB管理，ADB的安装，与ADB设备双向传输文件，打开网络ADB调试，查看互通IP，支持扫码连接。
## 注意！！！
这个仓库仍在大量开发维护中，但是由于平时工作缘故，所以不会有太多空闲的时间，相关的截图等都没来得及更新，见谅！！！
**需要编译大额联系github上的邮箱或者qq**

## 功能列表

- 扫码快速调试
- 管理 ADB 设备
- 快捷上传下载文件
- 向 ADB 设备安装 APK
- 为设备免 Root 开启 ADB
- 将 ADB 安装到系统
- 自定义执行命令
- 查看连接到当前设备的 IP
- 自动发现局域网设备

## 截图
### 安卓
### PC端
## 相比传统调试方式

### 传统方式：

在设备没有ROOT开启网络ADB调试需要连接上PC，并在PC安装ADB环境，并执行adb tcpip 5555，如果存在多个设备，还需要adb -s xxx tcpip 5555来区分。

### ADB工具：

PC打开ADB工具，手机数据线连接上PC，即可为设备一键打开网络ADB调试。

而对于有ROOT的设备，ADB工具也能提供在本机上一键打开网络ADB调试。

打开网络ADB调试后，无需在PC上执行 adb connect xxx，只需要在PC上启动ADB工具，打开连接二维码，手机使用ADB工具扫描即可连接。

## 测试平台

- Android：小米10、小米8青春版、红米4

- MacOS：macOS Catalina 10.15.7

- Linux：Manjaro 20.02

- Window：Win10 20H0

PC版下载[(链接)](http://nightmare.fun/adbtool/)

## 关于设备的发现功能

在 Android  热点，PC 端连接的情况，PC 端检测 Android 端 ADB TOOL 的启动会有延迟，具体视局域网而定。
简单说，PC 端监听 Android 比 Android 端监听 PC 端的延迟要高 。

### 相关资料

目前设备的发现是通过**组播**加**广播**实现的。

在尝试了[multicast_dns](https://github.com/flutter/packages/tree/master/packages/multicast_dns)后，并没有调通实例代码。
这是躺坑过程中的资料：[https://github.com/flutter/flutter/issues/16335](https://github.com/flutter/flutter/issues/16335)

Android 默认关闭组播，意味着，局域网其他设备发送的组播消息，Android 设备无法收到，这个问题已经通过内部的 plugin 进行了解决，目前存在的问题是：
在 Android 设备打开热点，PC 端连接的情况，PC 设备收不到来自 Android 设备的组播消息，所以监听UDP的代码中，同时支持了组播与广播，发送UDP也同时将
消息发送到组播地址与广播地址中。

