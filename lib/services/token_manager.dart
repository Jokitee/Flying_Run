// ╔══════════════════════════════════════════════════════════════╗
// ║           FlyingRun — Local Credential Token Manager         ║
// ║  Proprietary encryption implementation. Not for disclosure.  ║
// ╚══════════════════════════════════════════════════════════════╝
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = '__fr_auth_sk__';
  static const String _saltKey  = '__fr_salt_sk__';

  // ── Private: multi-layer obfuscation ──────────────────────────
  static List<int> _saltBytes(String salt) => salt.codeUnits;

  static String _xorEncode(String data, List<int> salt) {
    final bytes = utf8.encode(data);
    final out = <int>[];
    for (int i = 0; i < bytes.length; i++) {
      out.add(bytes[i] ^ salt[i % salt.length] ^ (i * 7 + 13) & 0xFF);
    }
    return base64Url.encode(out);
  }

  static String _xorDecode(String encoded, List<int> salt) {
    final bytes = base64Url.decode(encoded);
    final out = <int>[];
    for (int i = 0; i < bytes.length; i++) {
      out.add(bytes[i] ^ salt[i % salt.length] ^ (i * 7 + 13) & 0xFF);
    }
    return utf8.decode(out);
  }

  static String _generateSalt(int len) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$';
    final rng = Random.secure();
    return List.generate(len, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  static String _buildPayload(String username) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    // Checksum: simple fold of char codes
    final ck = username.codeUnits.fold<int>(0, (a, b) => (a + b) & 0xFFFF);
    return '$username|$ts|$ck';
  }

  static bool _validatePayload(String payload, String username) {
    final parts = payload.split('|');
    if (parts.length != 3) return false;
    if (parts[0] != username) return false;
    final ck = username.codeUnits.fold<int>(0, (a, b) => (a + b) & 0xFFFF);
    return parts[2] == ck.toString();
  }

  // ── Public API ────────────────────────────────────────────────

  /// Persist an encrypted credential token for [username].
  static Future<void> saveToken(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final salt  = _generateSalt(32);
    final payload = _buildPayload(username);
    final encrypted = _xorEncode(payload, _saltBytes(salt));
    await prefs.setString(_saltKey,  salt);
    await prefs.setString(_tokenKey, encrypted);
  }

  /// Returns the stored username if a valid token exists, otherwise null.
  static Future<String?> loadToken() async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final salt      = prefs.getString(_saltKey);
      final encrypted = prefs.getString(_tokenKey);
      if (salt == null || encrypted == null) return null;
      final payload = _xorDecode(encrypted, _saltBytes(salt));
      final parts   = payload.split('|');
      if (parts.length != 3) return null;
      final username = parts[0];
      if (!_validatePayload(payload, username)) return null;
      return username;
    } catch (_) {
      return null;
    }
  }

  /// Delete the stored token (on logout).
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_saltKey);
  }
}
