// ignore_for_file: constant_identifier_names

import 'package:adb_tool/config/font.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/cupertino.dart' show CupertinoThemeData;
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

import 'lib_color_schemes.g.dart';

class DefaultThemeData {
  DefaultThemeData._();
  static final Color _primary = AppColors.accent;

  static ThemeData dark() {
    final darkThemeData = ThemeData.dark();
    // ThemeData
    return darkThemeData.copyWith(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      primaryColor: darkColorScheme.primary,
      scaffoldBackgroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      primaryIconTheme: darkThemeData.iconTheme.copyWith(
        color: darkColorScheme.onSurface,
      ),
      iconTheme: darkThemeData.iconTheme.copyWith(
        color: darkColorScheme.onSurface,
      ),
      appBarTheme: darkThemeData.appBarTheme.copyWith(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: darkThemeData.iconTheme.copyWith(
          color: const Color(0xFFA8A8A8),
        ),
        actionsIconTheme: darkThemeData.iconTheme.copyWith(
          color: const Color(0xFF8C8C8C),
        ),
        toolbarTextStyle: darkThemeData.textTheme.headline6.copyWith(
          fontSize: Dimens.font_sp20,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFA8A8A8),
        ),
      ),
      tabBarTheme: darkThemeData.tabBarTheme.copyWith(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: Dimens.gap_dp2,
            color: darkColorScheme.onPrimary,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: darkColorScheme.onPrimary,
        labelStyle: TextStyle(
          fontSize: Dimens.font_sp16,
        ),
        labelPadding:
            EdgeInsets.only(top: Dimens.gap_dp8, bottom: Dimens.gap_dp10),
        unselectedLabelColor: darkColorScheme.onSurface,
        unselectedLabelStyle: TextStyle(
          fontSize: Dimens.font_sp16,
        ),
      ),
      unselectedWidgetColor: const Color(0xFF696969),
      toggleableActiveColor: _primary,
      dividerColor: darkColorScheme.outline,
      dividerTheme: DividerThemeData(
        color: darkColorScheme.outline,
        space: Dimens.gap_dp1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: darkColorScheme.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: darkColorScheme.primary.withOpacity(0.08),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.w,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.w),
          gapPadding: 0,
          borderSide: const BorderSide(
            width: 0,
            color: Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.w),
          gapPadding: 0,
          borderSide: const BorderSide(
            width: 0,
            color: Colors.transparent,
          ),
        ),
        filled: true,
      ),
      textTheme: darkThemeData.textTheme.copyWith(
        bodyText2: darkThemeData.textTheme.bodyText1.copyWith(
          fontSize: Dimens.font_sp14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFE7E7E7),
        ),
      ),
    );
  }

  static ThemeData light({
    Color primary,
  }) {
    final lightThemeData = ThemeData.light();
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: seed);
    return lightThemeData.copyWith(
      useMaterial3: true,
      primaryColor: colorScheme.primary,
      colorScheme: colorScheme,
      // Desktop有高斯模糊背景
      scaffoldBackgroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
      primaryIconTheme: lightThemeData.primaryIconTheme.copyWith(
        color: colorScheme.onSurface,
      ),
      iconTheme: lightThemeData.iconTheme.copyWith(
        color: colorScheme.onSurface,
      ),
      // cardTheme: CardTheme(),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colorScheme.primary.withOpacity(0.08),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.w,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.w),
          gapPadding: 0,
          borderSide: const BorderSide(
            width: 0,
            color: Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.w),
          gapPadding: 0,
          borderSide: const BorderSide(
            width: 0,
            color: Colors.transparent,
          ),
        ),
        filled: true,
      ),
      appBarTheme: lightThemeData.appBarTheme.copyWith(
        systemOverlayStyle: OverlayStyle.dark,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: lightThemeData.iconTheme.copyWith(
          color: const Color(0xFF595959),
        ),
        actionsIconTheme: lightThemeData.iconTheme.copyWith(
          color: colorScheme.primary,
        ),
        titleTextStyle: lightThemeData.textTheme.headline6.copyWith(
          fontSize: 18.w,
          fontWeight: bold,
          color: colorScheme.onBackground,
        ),
      ),
      tabBarTheme: lightThemeData.tabBarTheme.copyWith(
        indicator: UnderlineTabIndicator(
          borderSide:
              BorderSide(width: Dimens.gap_dp2, color: colorScheme.primary),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: colorScheme.primary,
        labelStyle: TextStyle(
          fontSize: Dimens.font_sp16,
        ),
        labelPadding:
            EdgeInsets.only(top: Dimens.gap_dp8, bottom: Dimens.gap_dp10),
        unselectedLabelColor: colorScheme.onSurface,
        unselectedLabelStyle: TextStyle(
          fontSize: Dimens.font_sp16,
        ),
      ),
      unselectedWidgetColor: const Color(0xFFBFBFBF),
      toggleableActiveColor: colorScheme.primary,
      dividerColor: colorScheme.outline,
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        space: Dimens.gap_dp1,
      ),
      cardColor: Colors.white,
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
      ),
      textTheme: lightThemeData.textTheme.copyWith(
        bodyText2: lightThemeData.textTheme.bodyText2.copyWith(
          fontSize: Dimens.font_sp14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground,
        ),
      ),
    );
  }
}
