import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:android_tool/android_tool.dart';
import '../generated/l10n.dart';

/// ADB KIT I18n Wrapper
/// let some views support multi-language when adb_kit as package
class AKI18nWrapper extends StatefulWidget {
  const AKI18nWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<AKI18nWrapper> createState() => _AKI18nWrapperState();
}

class _AKI18nWrapperState extends State<AKI18nWrapper> {
  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: Localizations.localeOf(context),
      delegates: const [
        P.delegate,
        IA.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: widget.child,
    );
  }
}
