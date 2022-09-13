LOCAL_DIR=$(
    cd $(dirname $0)
    pwd
)
PROJECT_DIR=$LOCAL_DIR/../..
source $LOCAL_DIR/../properties.sh
# echo $PROJECT_DIR
linux_app="$PROJECT_DIR/dist/$APP_NAME.deb"
if [ -f $linux_app ]; then
    rsync -v $linux_app "${TARGET_PATH}/${APP_NAME}_${VERSION}_Linux.deb"
fi
mac_app_tar="$PROJECT_DIR/dist/${APP_NAME}.tar"
if [ -f $mac_app_tar ]; then
    rsync -v $mac_app_tar ${TARGET_PATH}/${APP_NAME}_${VERSION}_macOS.tar
fi
mac_app="$PROJECT_DIR/dist/${APP_NAME}_macOS.tar"
if [ -f $mac_app ]; then
    rsync -v $mac_app ${TARGET_PATH}/${APP_NAME}_${VERSION}_macOS.tar
fi
win_app="$PROJECT_DIR/dist/${APP_NAME}_Windows.zip"
if [ -f $win_app ]; then
    target_name=$APP_NAME'_'$VERSION'_Windows.zip'
    echo "upload $target_name"
    rsync -v $win_app $TARGET_PATH/$target_name
fi
arm64_apk="$PROJECT_DIR/dist/app-arm64-v8a-release.apk"
if [ -f "$arm64_apk" ]; then
    rsync -v "$arm64_apk" $TARGET_PATH/${APP_NAME}_${VERSION}_Android_arm64.apk
fi
arm_apk="$PROJECT_DIR/dist/app-armeabi-v7a-release.apk"
if [ -f "$arm_apk" ]; then
    rsync -v "$arm_apk" $TARGET_PATH/${APP_NAME}_${VERSION}_Android_arm_v7a.apk
fi
x86_apk="$PROJECT_DIR/dist/app-x86_64-release.apk"
if [ -f "$x86_apk" ]; then
    rsync -v "$x86_apk" $TARGET_PATH/${APP_NAME}_${VERSION}_Android_x86_64.apk
fi
