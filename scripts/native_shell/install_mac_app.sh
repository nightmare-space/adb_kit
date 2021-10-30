sed -i '' '16s/false/true/' ./lib/main.dart
./scripts/native_shell/gen_release_app.sh
sed -i '' '16s/true/false/' ./lib/main.dart
cp -rf "target/ADB TOOL.app" /Applications/