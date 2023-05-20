LOCAL_DIR=$(
    cd $(dirname $0)
    pwd
)
echo $LOCAL_DIR
PROJECT_DIR=$LOCAL_DIR/..
echo $PROJECT_DIR
bin="$PROJECT_DIR/build/macos/Build/Products/Release/ADB TOOL.app/Contents/MacOS/data/usr/bin"
mkdir -p "$bin"
cp $PROJECT_DIR/res/macos/adb "$bin/"
chmod +x "$bin/adb"
