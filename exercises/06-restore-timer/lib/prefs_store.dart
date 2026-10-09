import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

/// Real storage on the watch, backed by shared_preferences.
///
/// `SharedPreferences.getInstance()` is async, but once you have the
/// instance, reads are instant. So we await it once in main() and pass it in.
/// Writes return a Future; we do not wait for them because the in-memory
/// copy is updated immediately.
class PrefsStore implements KeyValueStore {
  PrefsStore(this._prefs);
  final SharedPreferences _prefs;

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  void write(String key, String value) => _prefs.setString(key, value);

  @override
  void delete(String key) => _prefs.remove(key);
}
