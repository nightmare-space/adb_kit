LOCAL_DIR=$(
    cd $(dirname $0)
    pwd
)
PROJECT_DIR=$LOCAL_DIR/../..
source $LOCAL_DIR/../properties.sh
# echo $PROJECT_DIR
mac_app_tar="$PROJECT_DIR/dist/${APP_NAME}.tar"
if [ -f $mac_app_tar ]; then
    rsync -v $mac_app_tar ${TARGET_PATH}/${APP_NAME}_${VERSION}_macOS.tar
fi
mac_app="$PROJECT_DIR/dist/${APP_NAME}.dmg"
if [ -f $mac_app ]; then
    rsync -v $mac_app ${TARGET_PATH}/${APP_NAME}_${VERSION}_macOS.dmg
fi
if [ -f $PROJECT_DIR/$APP_NAME'_Windows.zip' ]; then
    target_name=$APP_NAME'_'$VERSION'_Windows.zip'
    echo "upload $target_name"
    rsync -v $PROJECT_DIR/$APP_NAME'_Windows.zip' $TARGET_PATH/$target_name
fi

rsync -v $PROJECT_DIR/dist/app-arm64-v8a-release.apk $TARGET_PATH/${APP_NAME_CN}_${VERSION}_Android_arm64.apk
rsync -v $PROJECT_DIR/dist/app-armeabi-v7a-release.apk $TARGET_PATH/${APP_NAME_CN}_${VERSION}_Android_arm_v7a.apk
rsync -v $PROJECT_DIR/dist/app-x86_64-release.apk $TARGET_PATH/${APP_NAME_CN}_${VERSION}_Android_x86_64.apk
