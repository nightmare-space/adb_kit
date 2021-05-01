flutter build macos
rm -rf ./build/macos/Build/Products/Release/移动到这
ln -s -f /Applications ./build/macos/Build/Products/Release/移动到这
mkdir -p "./build/macos/Build/Products/Release/ADB TOOL.app/Contents/MacOS/data/usr/bin"
cp ./executable/macos/adb "./build/macos/Build/Products/Release/ADB TOOL.app/Contents/MacOS/data/usr/bin"
tar -zcvf ./ADBTOOL.tar  -C ./build/macos/Build/Products/  "Release/ADB TOOL.app/" Release/移动到这
rm -rf ./build/macos/Build/Products/Release/移动到这