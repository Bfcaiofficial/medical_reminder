import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './../resources/labels.dart';

class LanguageProvider with ChangeNotifier {
  final _arabicLabels = ArabicLabels();
  final _englishLabels = EnglishLabels();
  String _langCode;
  bool _isLanguageLoaded = false;

  void setLanguage(String langCode) {
    _langCode = langCode;
  }

  get labelsProvider {
    if (_langCode == 'en') {
      return _englishLabels;
    } else if (_langCode == 'ar') {
      return _arabicLabels;
    }
  }

  String get langCode => _langCode;
  Future<String> get getLangCode async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('langCode');
  }

  void setLanguageLoaded() {
    _isLanguageLoaded = true;
  }

  bool get isLanguageLoaded => _isLanguageLoaded;
}
