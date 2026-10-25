// Supported languages.
// IMPORTANT: `apiName` must match the LANGUAGES list in api/analyze.js exactly.

class AppLanguage {
  /// Name sent to the backend / AI (English name).
  final String apiName;

  /// Name shown to the user, written in that language.
  final String nativeName;

  /// Locale used for Read Aloud (text-to-speech).
  final String ttsLocale;

  /// Right-to-left script (Arabic).
  final bool rtl;

  const AppLanguage(this.apiName, this.nativeName, this.ttsLocale, {this.rtl = false});
}

const List<AppLanguage> kLanguages = [
  AppLanguage('English', 'English', 'en-US'),
  AppLanguage('Hindi', 'हिन्दी', 'hi-IN'),
  AppLanguage('Punjabi', 'ਪੰਜਾਬੀ', 'pa-IN'),
  AppLanguage('Spanish', 'Español', 'es-US'),
  AppLanguage('Chinese (Simplified)', '简体中文', 'zh-CN'),
  AppLanguage('Vietnamese', 'Tiếng Việt', 'vi-VN'),
  AppLanguage('Korean', '한국어', 'ko-KR'),
  AppLanguage('Tagalog', 'Tagalog', 'fil-PH'),
  AppLanguage('Arabic', 'العربية', 'ar-SA', rtl: true),
  AppLanguage('Gujarati', 'ગુજરાતી', 'gu-IN'),
  AppLanguage('Bengali', 'বাংলা', 'bn-IN'),
  AppLanguage('Tamil', 'தமிழ்', 'ta-IN'),
  AppLanguage('Telugu', 'తెలుగు', 'te-IN'),
  AppLanguage('French', 'Français', 'fr-FR'),
  AppLanguage('Italian', 'Italiano', 'it-IT'),
  AppLanguage('Portuguese', 'Português', 'pt-BR'),
  AppLanguage('Russian', 'Русский', 'ru-RU'),
  AppLanguage('Farsi', 'فارسی', 'fa-IR', rtl: true),
  AppLanguage('Dari', 'دری', 'fa-AF', rtl: true),
  AppLanguage('Japanese', '日本語', 'ja-JP'),
];

AppLanguage languageByApiName(String name) =>
    kLanguages.firstWhere((l) => l.apiName == name, orElse: () => kLanguages.first);
