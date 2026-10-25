import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/analysis.dart';

/// Stores past RESULTS (text only) on the device. Photos are never saved.
class HistoryService {
  static const _historyKey = 'history_v1';
  static const _languageKey = 'language_v1';
  static const _maxItems = 20;

  static Future<List<Analysis>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? const [];
    final items = <Analysis>[];
    for (final s in raw) {
      try {
        final j = Map<String, dynamic>.from(jsonDecode(s) as Map);
        items.add(Analysis.fromJson(j, language: (j['_language'] as String?) ?? 'English'));
      } catch (_) {
        // Skip corrupted entries instead of crashing.
      }
    }
    return items;
  }

  static Future<void> add(Analysis a) async {
    if (!a.readable) return; // don't save blurry-photo results
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? <String>[];
    raw.insert(0, jsonEncode(a.toJson()));
    if (raw.length > _maxItems) raw.removeRange(_maxItems, raw.length);
    await prefs.setStringList(_historyKey, raw);
  }

  static Future<void> removeAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? <String>[];
    if (index >= 0 && index < raw.length) {
      raw.removeAt(index);
      await prefs.setStringList(_historyKey, raw);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  static Future<String?> savedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  static Future<void> saveLanguage(String apiName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, apiName);
  }
}
