// SaveRepository implementations. Local-first: shared_preferences maps to
// localStorage on web and platform key-value stores on mobile/desktop.
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/player.dart';
import 'save_codec.dart';

class InMemorySaveRepository implements SaveRepository {
  InMemorySaveRepository({this.codec = const SaveCodec()});
  final SaveCodec codec;
  String? _stored;

  /// Raw stored payload, useful for tests that simulate a fresh process.
  String? get stored => _stored;

  @override
  Future<SaveGame?> load() async =>
      _stored == null ? null : codec.decode(_stored!);

  @override
  Future<void> save(SaveGame save) async => _stored = codec.encode(save);

  @override
  Future<void> clear() async => _stored = null;
}

class SharedPreferencesSaveRepository implements SaveRepository {
  SharedPreferencesSaveRepository({
    this.key = 'iron_ascent.save',
    this.codec = const SaveCodec(),
    SharedPreferencesAsync? preferences,
  }) : _prefs = preferences ?? SharedPreferencesAsync();

  final String key;
  final SaveCodec codec;
  final SharedPreferencesAsync _prefs;

  @override
  Future<SaveGame?> load() async {
    final raw = await _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    return codec.decode(raw);
  }

  @override
  Future<void> save(SaveGame save) => _prefs.setString(key, codec.encode(save));

  @override
  Future<void> clear() => _prefs.remove(key);
}
