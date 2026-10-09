// A tiny storage interface.
//
// The controller only needs "read a string, write a string, delete a string".
// Depending on this interface (not on shared_preferences directly) means
//   * tests use InMemoryStore and need no platform code, and
//   * the app uses PrefsStore (see prefs_store.dart) for real saving.

abstract interface class KeyValueStore {
  String? read(String key);
  void write(String key, String value);
  void delete(String key);
}

/// Keeps everything in a Map. It survives as long as the object does, which
/// is exactly what we need to PRETEND the process died: build a second
/// controller around the same store.
class InMemoryStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  String? read(String key) => _data[key];

  @override
  void write(String key, String value) => _data[key] = value;

  @override
  void delete(String key) => _data.remove(key);
}
