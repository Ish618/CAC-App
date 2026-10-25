import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/analysis.dart';

/// Where the backend lives.
/// - Deployed on Vercel (same domain as the app): leave empty → uses "/api/analyze".
/// - Testing against a different server: run with
///   flutter run -d chrome --dart-define=API_BASE=https://your-app.vercel.app
const String kApiBase = String.fromEnvironment('API_BASE', defaultValue: '');

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const _timeout = Duration(seconds: 60);

  /// Accepts one or more page images (first page sets the detected type).
  static Future<Analysis> analyze({
    required List<Uint8List> pages,
    required String language,
  }) async {
    if (pages.isEmpty) {
      throw ApiException('Please add at least one page.');
    }
    final uri = Uri.parse('$kApiBase/api/analyze');

    final http.Response res;
    try {
      res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'images': pages.map(base64Encode).toList(),
              'mimeType': _detectMime(pages.first),
              'language': language,
            }),
          )
          .timeout(_timeout);
    } catch (_) {
      throw ApiException('Could not connect. Check your internet and try again.');
    }

    Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(utf8.decode(res.bodyBytes)) as Map);
    } catch (_) {
      throw ApiException('The server sent an unexpected answer. Please try again.');
    }

    if (res.statusCode != 200) {
      throw ApiException((body['error'] as String?) ?? 'Something went wrong. Please try again.');
    }

    return Analysis.fromJson(body, language: language);
  }

  /// Detects the image type from its first bytes (the picker doesn't always tell us).
  static String _detectMime(Uint8List b) {
    if (b.length >= 4 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
      return 'image/png';
    }
    if (b.length >= 12 &&
        b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return 'image/webp';
    }
    if (b.length >= 12 && b[4] == 0x66 && b[5] == 0x74 && b[6] == 0x79 && b[7] == 0x70) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }
}
