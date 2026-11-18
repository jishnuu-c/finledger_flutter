import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? lookupAppLocalizations(const Locale('en'));
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}

class LocaleNotifier extends Notifier<Locale> {
  static const String _keyLocale = 'fl_selected_locale';

  @override
  Locale build() {
    _loadSavedLocale();
    return const Locale('en');
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_keyLocale);
    if (savedCode != null && ['en', 'hi', 'ar'].contains(savedCode)) {
      if (state.languageCode != savedCode) {
        state = Locale(savedCode);
      }
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!['en', 'hi', 'ar'].contains(newLocale.languageCode)) return;
    state = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, newLocale.languageCode);
  }

  Future<void> setLanguageCode(String code) async {
    await setLocale(Locale(code));
  }
}

final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
