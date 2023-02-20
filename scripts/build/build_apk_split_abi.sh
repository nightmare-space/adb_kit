# 分abi打包脚本
flutter build apk --obfuscate --split-debug-info -t lib/main.dart --split-per-abi
# flutter build apk --tree-shake-icons --split-per-abi
LOCAL_DIR=$(
    cd $(dirname $0)
    pwd
)
PROJECT_DIR=$LOCAL_DIR/../..
mkdir $PROJECT_DIR/dist/ 2>/dev/null
cp -f $PROJECT_DIR/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk $PROJECT_DIR/dist/
cp -f $PROJECT_DIR/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk $PROJECT_DIR/dist/
cp -f $PROJECT_DIR/build/app/outputs/flutter-apk/app-x86_64-release.apk $PROJECT_DIR/dist/
# ✓  Built build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (14.8MB).
# ✓  Built build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (17.5MB).
# ✓  Built build/app/outputs/flutter-apk/app-x86_64-release.apk (14.7MB).

