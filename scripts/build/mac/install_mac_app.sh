# flutter clean
LOCAL_DIR=$(
    cd $(dirname $0)
    pwd
)
PROJECT_DIR=$LOCAL_DIR/../../..
source $PROJECT_DIR/scripts/properties.sh
flutter build macos
$PROJECT_DIR/scripts/patch_executable.sh
cp -rf "./build/macos/Build/Products/Release/ADB TOOL.app" "/Applications/"