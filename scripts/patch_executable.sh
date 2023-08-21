LOCAL_DIR=$(
    cd $(dirname $0)
    pwd
)
PROJECT_DIR=$LOCAL_DIR/..
source $PROJECT_DIR/scripts/properties.sh
bin="$PROJECT_DIR/build/macos/Build/Products/Release/$MAC_APP_NAME.app/Contents/MacOS/data/usr/bin"
mkdir -p "$bin"
cp $PROJECT_DIR/res/macos/adb "$bin/"
chmod +x "$bin/adb"
