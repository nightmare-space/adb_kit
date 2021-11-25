app_path="build/macos/Build/Products/Release"
flutter build macos
rm -rf "$app_path/移动到这"
ln -s -f /Applications "$app_path/移动到这"
mkdir -p "$app_path/ADB TOOL.app/Contents/MacOS/data/usr/bin"
cp ./executable/macos/adb "$app_path/ADB TOOL.app/Contents/MacOS/data/usr/bin"
tar -zcvf ./AdbTool_macOS.tar  -C ./build/macos/Build/Products/  "Release/ADB TOOL.app/" Release/移动到这
rm -rf "$app_path/移动到这"