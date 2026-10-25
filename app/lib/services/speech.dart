import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../languages.dart';

/// Read Aloud using the device's built-in voices (free).
class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  /// Which button (or object) is currently speaking. null = silent.
  final ValueNotifier<Object?> owner = ValueNotifier<Object?>(null);

  Future<void> _init() async {
    _tts.setCompletionHandler(() => owner.value = null);
    _tts.setErrorHandler((_) => owner.value = null);
    try {
      // Rates differ by platform: web 1.0 = normal, iOS/Android 0.5 = normal.
      await _tts.setSpeechRate(kIsWeb ? 0.85 : 0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
    } catch (_) {/* some platforms ignore these */}
  }

  /// Returns false if no voice exists for this language on the device.
  Future<bool> speak(String text, AppLanguage lang, {Object? owner}) async {
    if (!_initialized) {
      await _init();
      _initialized = true;
    }
    await stop();

    try {
      final available = await _tts.isLanguageAvailable(lang.ttsLocale);
      if (available == false) return false;
    } catch (_) {/* not supported on every platform; just try */}

    try {
      await _tts.setLanguage(lang.ttsLocale);
      this.owner.value = owner ?? this;
      await _tts.speak(text);
      return true;
    } catch (_) {
      this.owner.value = null;
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    owner.value = null;
  }
}
