import 'package:shared_preferences/shared_preferences.dart';
class AccountScopedStorage {
  static const _activeUserKey = '__active_user_id__';

  final SharedPreferences _prefs;
  final String _namespace;

  AccountScopedStorage._(this._prefs, this._namespace);
  static Future<AccountScopedStorage> forCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_activeUserKey);
    if (uid == null || uid.isEmpty) {
      throw StateError('No active user – call setActiveUser first');
    }
    return AccountScopedStorage._(prefs, 'user_${uid}_');
  }
  static Future<void> setActiveUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, userId);
  }
  static Future<String?> getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeUserKey);
  }
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeUserKey);
  }
  static Future<void> clearCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_activeUserKey);
    if (uid != null) {
      final namespace = 'user_${uid}_';
      final keys = prefs.getKeys().where((k) => k.startsWith(namespace));
      for (final k in keys) {
        await prefs.remove(k);
      }
    }
    await prefs.remove(_activeUserKey);
  }

  String _k(String key) => '$_namespace$key';

  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(_k(key), value);

  List<String>? getStringList(String key) =>
      _prefs.getStringList(_k(key));

  Future<bool> setString(String key, String value) =>
      _prefs.setString(_k(key), value);

  String? getString(String key) => _prefs.getString(_k(key));

  Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(_k(key), value);

  bool? getBool(String key) => _prefs.getBool(_k(key));

  Future<bool> setInt(String key, int value) =>
      _prefs.setInt(_k(key), value);

  int? getInt(String key) => _prefs.getInt(_k(key));

  Future<bool> remove(String key) => _prefs.remove(_k(key));

  Set<String> getKeys() => _prefs
      .getKeys()
      .where((k) => k.startsWith(_namespace))
      .map((k) => k.substring(_namespace.length))
      .toSet();
}
