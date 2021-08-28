version='1.1.3'
app_name='AdbTool'
target=root@$server:/home/nightmare/YanTool/resources/AdbTool
if [ -f "$app_name\_macOS.tar" ]; then
    rsync -v "$app_name\_macOS.tar" "$target/$app_name\_$version\_macOS.tar"
fi
rsync -v build/app/outputs/apk/release/app-release.apk "$target/$app_name\_$version\_Android_arm64.apk"
