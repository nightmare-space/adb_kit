import 'package:settings/settings.dart';

class Settings {
  static const serverPath = 'server_path';
  static const language = 'Language';
  static const theme = 'Theme';
  static const showStatusbar = 'ShowStatusbar';
  static const primaryColor = 'PrimaryColor';
  static const autoConnectDevice = 'AutoConnectDevice';
  static const screenType = 'ScreenType';
  static const backgroundStyle = 'BackgroundStyle';
  static const adbPassword = 'ADBPassword';

  static final SettingNode serverPathSetting = serverPath.setting;
  static final SettingNode languageSetting = language.setting;
  static final SettingNode themeSetting = theme.setting;
  static final SettingNode showStatusbarSetting = showStatusbar.setting;
  static final SettingNode primaryColorSetting = primaryColor.setting;
  static final SettingNode autoConnectDeviceSetting = autoConnectDevice.setting;
  static final SettingNode screenTypeSetting = screenType.setting;
  static final SettingNode backgroundStyleSetting = backgroundStyle.setting;
  static final SettingNode adbPasswordSetting = adbPassword.setting;
}
