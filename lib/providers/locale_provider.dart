import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_config.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  static const String _prefKey = 'selected_locale';

  LocaleNotifier() : super(AppConfig.defaultLocale) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && (saved == 'bn' || saved == 'en')) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> toggleLocale() async {
    final next = state == 'bn' ? 'en' : 'bn';
    setLocale(next);
  }

  Future<void> setLocale(String localeCode) async {
    if (localeCode != 'bn' && localeCode != 'en') return;
    state = localeCode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, localeCode);
    } catch (_) {}
  }

  bool get isBangla => state == 'bn';
  bool get isEnglish => state == 'en';
}
