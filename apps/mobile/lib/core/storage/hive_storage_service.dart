import 'package:hive_ce_flutter/hive_flutter.dart';

abstract class IHiveStorageService {
  Future<void> init();
  Future<void> put<T>(String boxName, String key, T value);
  T? get<T>(String boxName, String key, {T? defaultValue});
  Future<void> delete(String boxName, String key);
  Future<void> clearBox(String boxName);
}

class HiveStorageService implements IHiveStorageService {
  static const String boxCache = 'app_cache';
  static const String boxSettings = 'app_settings';

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxCache);
    await Hive.openBox(boxSettings);
  }

  @override
  Future<void> put<T>(String boxName, String key, T value) async {
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
    await box.put(key, value);
  }

  @override
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    if (!Hive.isBoxOpen(boxName)) return defaultValue;
    final box = Hive.box(boxName);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  @override
  Future<void> delete(String boxName, String key) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).delete(key);
    }
  }

  @override
  Future<void> clearBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).clear();
    }
  }
}
