# flutter clean
flutter build macos
./scripts/patch_executable.sh
mv -f "./build/macos/Build/Products/Release/ADB TOOL.app" "/Applications/ADB TOOL.app"