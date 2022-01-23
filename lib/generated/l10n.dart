// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance;
  }

  static S maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Auto connect device in LAN`
  String get autoConnectDevice {
    return Intl.message(
      'Auto connect device in LAN',
      name: 'autoConnectDevice',
      desc: '',
      args: [],
    );
  }

  /// `Responsive`
  String get autoFit {
    return Intl.message(
      'Responsive',
      name: 'autoFit',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Debug Paint Layer Borders Enabled`
  String get debugPaintLayerBordersEnabled {
    return Intl.message(
      'Debug Paint Layer Borders Enabled',
      name: 'debugPaintLayerBordersEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Debug Paint Pointers Enabled`
  String get debugPaintPointersEnabled {
    return Intl.message(
      'Debug Paint Pointers Enabled',
      name: 'debugPaintPointersEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Debug Paint Size Enabled`
  String get debugPaintSizeEnabled {
    return Intl.message(
      'Debug Paint Size Enabled',
      name: 'debugPaintSizeEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Show Repaint Rainbow`
  String get debugRepaintRainbowEnabled {
    return Intl.message(
      'Show Repaint Rainbow',
      name: 'debugRepaintRainbowEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Debug Show Material Grid`
  String get debugShowMaterialGrid {
    return Intl.message(
      'Debug Show Material Grid',
      name: 'debugShowMaterialGrid',
      desc: '',
      args: [],
    );
  }

  /// `Desktop`
  String get desktop {
    return Intl.message(
      'Desktop',
      name: 'desktop',
      desc: '',
      args: [],
    );
  }

  /// `Developer Settings`
  String get developerSettings {
    return Intl.message(
      'Developer Settings',
      name: 'developerSettings',
      desc: '',
      args: [],
    );
  }

  /// `fix some device without \n/data/local/tmp permission`
  String get fixDeviceWithoutDataLocalPermission {
    return Intl.message(
      'fix some device without \n/data/local/tmp permission',
      name: 'fixDeviceWithoutDataLocalPermission',
      desc: '',
      args: [],
    );
  }

  /// `History Connect`
  String get historyConnect {
    return Intl.message(
      'History Connect',
      name: 'historyConnect',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Install to System`
  String get installToSystem {
    return Intl.message(
      'Install to System',
      name: 'installToSystem',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Layout Style`
  String get layout {
    return Intl.message(
      'Layout Style',
      name: 'layout',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Log`
  String get log {
    return Intl.message(
      'Log',
      name: 'log',
      desc: '',
      args: [],
    );
  }

  /// `LAN debug`
  String get networkDebug {
    return Intl.message(
      'LAN debug',
      name: 'networkDebug',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message(
      'Other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Pad`
  String get pad {
    return Intl.message(
      'Pad',
      name: 'pad',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Primary Color`
  String get primaryColor {
    return Intl.message(
      'Primary Color',
      name: 'primaryColor',
      desc: '',
      args: [],
    );
  }

  /// `Server Path`
  String get serverPath {
    return Intl.message(
      'Server Path',
      name: 'serverPath',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get setting {
    return Intl.message(
      'Setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Show Performance Overlay`
  String get showPerformanceOverlay {
    return Intl.message(
      'Show Performance Overlay',
      name: 'showPerformanceOverlay',
      desc: '',
      args: [],
    );
  }

  /// `Show Semantics Debugger`
  String get showSemanticsDebugger {
    return Intl.message(
      'Show Semantics Debugger',
      name: 'showSemanticsDebugger',
      desc: '',
      args: [],
    );
  }

  /// `Terminal`
  String get terminal {
    return Intl.message(
      'Terminal',
      name: 'terminal',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message(
      'View',
      name: 'view',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
