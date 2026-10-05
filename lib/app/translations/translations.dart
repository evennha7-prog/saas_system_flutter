/// ==============================================================================
/// KITLUY POS / AudiCafe - App Translations Setup
/// ==============================================================================
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'en_us.dart';
import 'km_kh.dart';

class LanguageModel {
  final String name;
  final String subName;
  final String languageCode;
  final String countryCode;
  final String flag;

  const LanguageModel({
    required this.name,
    required this.subName,
    required this.languageCode,
    required this.countryCode,
    required this.flag,
  });

  Locale get locale => Locale(languageCode, countryCode);
}

class AppTranslations extends Translations {
  static const Locale defaultLocale = Locale('km', 'KH');
  static const Locale fallbackLocale = Locale('en', 'US');

  static final List<LanguageModel> languages = [
    const LanguageModel(
      name: 'ភាសាខ្មែរ',
      subName: 'Khmer',
      languageCode: 'km',
      countryCode: 'KH',
      flag: '🇰🇭',
    ),
    const LanguageModel(
      name: 'English',
      subName: 'English',
      languageCode: 'en',
      countryCode: 'US',
      flag: '🇺🇸',
    ),
  ];

  static void changeLocale(Locale locale) {
    Get.updateLocale(locale);
  }

  static LanguageModel get currentLanguage {
    final current = Get.locale ?? defaultLocale;
    return languages.firstWhere(
      (lang) => lang.languageCode == current.languageCode,
      orElse: () => languages.first,
    );
  }

  @override
  Map<String, Map<String, String>> get keys => {
    'km_KH': kmKH,
    'en_US': enUS,
  };
}
