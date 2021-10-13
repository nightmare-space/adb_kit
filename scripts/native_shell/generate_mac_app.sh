app_path="target"
mkdir $app_path
rm -rf "$app_path/移动到这"
ln -s -f /Applications "$app_path/移动到这"
cargo build --release
rm -rf "target/ADB TOOL.app"
cargo bundle-tool -v macos-bundle "target/release/ADB TOOL.app" target/
./scripts/native_shell/patch_executable.sh
tar -zcvf ./AdbTool_macOS.tar  -C $app_path/ "ADB TOOL.app/" "移动到这"
rm -rf "$app_path/移动到这"