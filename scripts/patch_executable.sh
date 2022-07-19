bin="./build/macos/Build/Products/Release/ADB TOOL.app/Contents/MacOS/data/usr/bin"
mkdir -p "$bin"
cp ./res/macos/adb "$bin/"
chmod +x "$bin/adb"
