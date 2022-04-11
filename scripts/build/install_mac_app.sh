# flutter clean
flutter build macos
./scripts/patch_executable.sh
cp -rf "./build/macos/Build/Products/Release/ADB TOOL.app" /Applications/