sed -i '' '20s/false/true/' ./lib/main.dart
cargo build --release
rm -rf "target/ADB TOOL.app"
cargo bundle-tool -v macos-bundle "target/release/ADB TOOL.app" target/
./scripts/native_shell/patch_executable.sh
sed -i '' '20s/true/false/' ./lib/main.dart