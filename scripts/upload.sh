target=root@$server:/home/nightmare/YanTool/resources/AdbTool
rsync -v AdbTool_macOS.tar $target/
rsync -v build/app/outputs/apk/release/app-release.apk $target/AdbTool_android_arm64.apk