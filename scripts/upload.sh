version='1.1.2'
target=root@$server:/home/nightmare/YanTool/resources/AdbTool
if [ -f "AdbTool_macOS.tar" ]; then
    rsync -v "AdbTool_macOS.tar" "$target/AdbTool_$version\_macOS.tar"
fi
rsync -v build/app/outputs/apk/release/app-release.apk "$target/AdbTool_$version\_Android_arm64.apk"