# 计算出定义 bool 的代码行数
line=`cat ./lib/main.dart | grep -n "bool useNativeShell" | awk -F ":" '{print \$1}'`
sed -i '' $line's/false/true/' ./lib/main.dart
cargo build --release
rm -rf "target/ADB TOOL.app"
cargo bundle-tool -v macos-bundle "target/release/ADB TOOL.app" target/
./scripts/native_shell/patch_executable.sh
sed -i '' $line's/true/false/' ./lib/main.dart