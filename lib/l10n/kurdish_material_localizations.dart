import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class KurdishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const KurdishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // We default to English strings for Material widgets (Copy, Paste, etc.)
    // but the directionality (RTL) will be handled by the MaterialApp's locale.
    return await GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(KurdishMaterialLocalizationsDelegate old) => false;
}
