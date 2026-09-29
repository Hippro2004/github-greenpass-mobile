import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationReadStore {
  static const _storage = FlutterSecureStorage();
  static const _prefix = 'gp_read_notifs_';
  static final Map<String, Set<String>> _memoryCache = {};

  static Future<Set<String>> getReadIds(String username) async {
    final cached = _memoryCache[username];
    if (cached != null) {
      return Set<String>.from(cached);
    }

    try {
      final raw = await _storage.read(key: '$_prefix$username');
      if (raw != null && raw.isNotEmpty) {
        final decoded = json.decode(raw);
        if (decoded is List) {
          final set = decoded.map((e) => e.toString()).toSet();
          _memoryCache[username] = set;
          return Set<String>.from(set);
        }
      }
    } catch (_) {}

    _memoryCache[username] = <String>{};
    return <String>{};
  }

  static Future<void> markAsRead(String username, int id) async {
    try {
      final set = await getReadIds(username);
      set.add(id.toString());
      _memoryCache[username] = set;
      await _storage.write(
        key: '$_prefix$username',
        value: json.encode(set.toList()),
      );
    } catch (_) {
      _memoryCache.putIfAbsent(username, () => <String>{}).add(id.toString());
    }
  }

  static Future<void> markAllAsRead(String username, Iterable<int> ids) async {
    try {
      final set = await getReadIds(username);
      set.addAll(ids.map((e) => e.toString()));
      _memoryCache[username] = set;
      await _storage.write(
        key: '$_prefix$username',
        value: json.encode(set.toList()),
      );
    } catch (_) {
      _memoryCache
          .putIfAbsent(username, () => <String>{})
          .addAll(ids.map((e) => e.toString()));
    }
  }
}
