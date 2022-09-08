rm -rf ./tmp
PACKAGE_DIR=./tmp
target_dir=$PACKAGE_DIR/opt/adb-kit
mkdir -p $target_dir
mkdir -p $PACKAGE_DIR/usr/share/applications
ICON_PATH=$PACKAGE_DIR/usr/share/pixmaps
mkdir -p $ICON_PATH
cp -rf ./build/linux/x64/release/bundle/. $target_dir
cp -rf ./res/linux/adb-kit.png $ICON_PATH/
cp -rf ./res/linux/adb-kit.desktop $PACKAGE_DIR/usr/share/applications/
mkdir $PACKAGE_DIR/DEBIAN
echo "
Package: adb-kit
Architecture: amd64
Maintainer: @Nightmare
Version: 1.3.1-1
Homepage: https://nightmare.fun/adb/
Description: adb binary GUI
">$PACKAGE_DIR/DEBIAN/control
dpkg-deb -b $PACKAGE_DIR "ADBKIT.deb"