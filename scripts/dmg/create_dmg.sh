APP_NAME="ADB KIT"
DMG_FILE_NAME="${APP_NAME}-Installer.dmg"
rm "$DMG_FILE_NAME"
VOLUME_NAME="${APP_NAME} Installer"
SOURCE_FOLDER_PATH="$PROJECT_DIR/build/macos/Build/Products/Release/"
create-dmg \
  --volname "${VOLUME_NAME}" \
  --window-pos 200 120 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 0 150 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 280 150 \
  "$DMG_FILE_NAME" \
  "${SOURCE_FOLDER_PATH}"