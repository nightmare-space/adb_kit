# ADB工具
不仅是在PC上，在安卓也能支持ADB设备，支持Android、Windows、macOS、Linux，在各个平台统一操作与UI，提供更方便的ADB管理，ADB的安装，与ADB设备双向传输文件，打开网络ADB调试，查看互通IP，支持扫码连接。

## 功能列表

- 扫码快速调试
- 管理 ADB 设备
- 快捷上传下载文件
- 向 ADB 设备安装 APK
- 为设备免 Root 开启 ADB
- 将 ADB 安装到系统
- 自定义执行命令
- 查看连接到当前设备的 IP

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
## 开始使用

如果你是```Flutter```开发者，你只需要在yaml文件声明这个packages，在组件的代码输入```AdbTool```，编辑器即可自动帮助你导入代码。
它的使用就像这么简单。
## 获取ADB执行文件
在 Adb 组件使用的时候，会先进行判断本机的环境变量中是否有adb可执行程序，如果没有，会选择从本人的一个服务器路径下载所需要的可执行文件路径。
在以下四个设备上

- linux
- macOS
- windows
- android

## Q&A
### 沙盒问题
在需要重新执行```flutter create .```来创建windows/linux/macos的情况下，由于mac桌面端是默认开启沙盒模式，所以在运行时你会遇见如下报错。
Operation not permitted
所以你需要用xcode打开对应的mac工程来关闭沙盒模式即可。

### 提示 SocketException: Connection failed
用 xode 打开 macos/Runner.xcodeproj 找到 Runner -> TARGET/Runner -> info
添加`App Transport Security Settings`并添加子项`Allow Arbitrary Loads`并设置为true
### 始终是unauthorized
需要保证对方设备此时还没有被另外的adb连接。

# test