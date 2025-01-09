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

class P {
  P();

  static P? _current;

  static P get current {
    assert(_current != null,
        'No instance of P was loaded. Try to initialize the P delegate before accessing P.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<P> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = P();
      P._current = instance;

      return instance;
    });
  }

  static P of(BuildContext context) {
    final instance = P.maybeOf(context);
    assert(instance != null,
        'No instance of P present in the widget tree. Did you add P.delegate in localizationsDelegates?');
    return instance!;
  }

  static P? maybeOf(BuildContext context) {
    return Localizations.of<P>(context, P);
  }

  /// `File Manager`
  String get file_manager {
    return Intl.message(
      'File Manager',
      name: 'file_manager',
      desc: '',
      args: [],
    );
  }

  /// `Common Switch`
  String get common_switch {
    return Intl.message(
      'Common Switch',
      name: 'common_switch',
      desc: '',
      args: [],
    );
  }

  /// `Screenshot`
  String get screenshot {
    return Intl.message(
      'Screenshot',
      name: 'screenshot',
      desc: '',
      args: [],
    );
  }

  /// `Display Touch Feedback`
  String get display_touch {
    return Intl.message(
      'Display Touch Feedback',
      name: 'display_touch',
      desc: '',
      args: [],
    );
  }

  /// `Display Screen Pointer`
  String get displayScreenPointer {
    return Intl.message(
      'Display Screen Pointer',
      name: 'displayScreenPointer',
      desc: '',
      args: [],
    );
  }

  /// `Show Layoutboundary`
  String get showLayoutboundary {
    return Intl.message(
      'Show Layoutboundary',
      name: 'showLayoutboundary',
      desc: '',
      args: [],
    );
  }

  /// `Install Apk`
  String get install_apk {
    return Intl.message(
      'Install Apk',
      name: 'install_apk',
      desc: '',
      args: [],
    );
  }

  /// `Upload File`
  String get upload_file {
    return Intl.message(
      'Upload File',
      name: 'upload_file',
      desc: '',
      args: [],
    );
  }

  /// `Drop here or`
  String get drop_tip {
    return Intl.message(
      'Drop here or',
      name: 'drop_tip',
      desc: '',
      args: [],
    );
  }

  /// `Click to select file`
  String get select_tip {
    return Intl.message(
      'Click to select file',
      name: 'select_tip',
      desc: '',
      args: [],
    );
  }

  /// `Remote Adb Debug`
  String get remoteAdbDebug {
    return Intl.message(
      'Remote Adb Debug',
      name: 'remoteAdbDebug',
      desc: '',
      args: [],
    );
  }

  /// `Without Root`
  String get remoteDebuSwitchgDes {
    return Intl.message(
      'Without Root',
      name: 'remoteDebuSwitchgDes',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get currentDebug {
    return Intl.message(
      'Current',
      name: 'currentDebug',
      desc: '',
      args: [],
    );
  }

  /// `Remote`
  String get remoteDebugDes {
    return Intl.message(
      'Remote',
      name: 'remoteDebugDes',
      desc: '',
      args: [],
    );
  }

  /// `Installing {name} ...`
  String installingApk(Object name) {
    return Intl.message(
      'Installing $name ...',
      name: 'installingApk',
      desc: '',
      args: [name],
    );
  }

  /// `Uploading {name} ...`
  String uploadingFile(Object name) {
    return Intl.message(
      'Uploading $name ...',
      name: 'uploadingFile',
      desc: '',
      args: [name],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<P> {
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
  Future<P> load(Locale locale) => P.load(locale);
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
