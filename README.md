# adb_tool

咋合适一个能够更方便的管理adb的工具，如果你更熟练的使用命令行，


## 开始使用

如果你是```Flutter```开发者，你只需要在yaml文件声明这个packages，在组件的代码输入```AdbTool```，编辑器即可自动帮助你导入代码。
它的使用就像这么简单。
## 获取ADB执行文件
在Adb组件使用的时候，会先进行判断本机的环境变量中是否有adb可执行程序，如果没有，会选择从本人的一个服务器路径下载所需要的可执行文件路径。
在以下四个设备上

- linux
-  macos
-  windows
-  android

## 功能列表
## windows / macos / linux
- [ ] 管理adb设备
- [ ] 安装adb到环境变量
## Q&A
在需要重新执行```flutter create .```来创建windows/linux/macos的情况下，由于mac桌面端是默认开启沙盒模式，所以在运行时你会遇见如下报错。
Operation not permitted
所以你需要用xcode打开对应的mac工程来关闭沙盒模式即可
### 始终是unauthorized
需要保证对方设备此时还没有被另外的adb连接。