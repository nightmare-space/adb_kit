import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'theme.dart';

ThemeData light({
  Color? primary,
}) {
  // Theme.of(context).colorScheme.tertiary
  final lightThemeData = ThemeData.light(useMaterial3: true);
  ColorScheme colorScheme = ColorScheme.fromSeed(
    // TODO 搞清楚这是个啥
    // tonalSpot（默认值）：为 Material 主题颜色提供默认风格，构建低色度的柔和色板。
    // fidelity：生成的色板更贴近种子颜色，即使种子颜色非常明亮（高色度）也能保持其特性。
    // monochrome：所有颜色都是灰度的，没有色度。
    // neutral：接近灰度，但保留少量色度。
    // vibrant：柔和色彩，高色度色板。主要色板的色度达到最大。若需要色调调整以匹配色板的活力，推荐使用 fidelity。
    // expressive：柔和色彩，中等色度色板。主要色板的色调与种子颜色不同，以增加多样性。
    // content：几乎与 fidelity 相同。组件和色板匹配种子颜色。primaryContainer 是经过调整的种子颜色，确保与表面颜色形成对比。第三级色板是种子颜色的类似色。
    // rainbow：一个活泼的主题，种子颜色的色调不会出现在主题中。
    // fruitSalad：另一个活泼的主题，种子颜色的色调不会出现在主题中。
    // dynamicSchemeVariant: ,
    seedColor: seed,
    brightness: Brightness.light,
    surface: const Color(0xfff3f4f9),
    surfaceContainer: const Color(0xffe8e9ee),
  );
  return lightThemeData.copyWith(
    primaryColor: colorScheme.primary,
    scaffoldBackgroundColor: colorScheme.surface,
    primaryIconTheme: lightThemeData.primaryIconTheme.copyWith(color: colorScheme.onSurface),
    iconTheme: lightThemeData.iconTheme.copyWith(color: colorScheme.onSurface),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: colorScheme.surface,
      hintStyle: TextStyle(fontSize: 14.w, color: colorScheme.onSurface),
      labelStyle: TextStyle(fontSize: 14.w, color: colorScheme.onSurface),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: GetPlatform.isMobile ? 10.w : 12.w,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.w),
        gapPadding: 0,
        borderSide: const BorderSide(width: 0, color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.w),
        gapPadding: 0,
        borderSide: const BorderSide(width: 0, color: Colors.transparent),
      ),
      filled: true,
    ),
    appBarTheme: lightThemeData.appBarTheme.copyWith(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      centerTitle: true,
      backgroundColor: colorScheme.surface,
      // when scaffold has scroll view and position >0 will use this color
      surfaceTintColor: colorScheme.surface,
      elevation: 0,
      actionsIconTheme: lightThemeData.iconTheme.copyWith(color: colorScheme.primary),
      titleTextStyle: lightThemeData.textTheme.titleLarge!.copyWith(fontSize: 18.w, fontWeight: FontWeight.bold),
    ),
    dividerColor: colorScheme.outline,
    dividerTheme: DividerThemeData(color: colorScheme.outline, space: 1.w),
    popupMenuTheme: PopupMenuThemeData(color: colorScheme.surface),
    textTheme: lightThemeData.textTheme.copyWith(
      bodyMedium: TextStyle(
        fontSize: 14.w,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        fontFamily: 'MiSans',
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return null;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return null;
      }),
    ),
    colorScheme: colorScheme,
  );
}
