import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/hive_storage_service.dart';

class LocaleCubit extends Cubit<Locale> {
  final IHiveStorageService _hiveStorage;

  static const String _keyLanguageCode = 'app_language_code';

  LocaleCubit(this._hiveStorage) : super(const Locale('ar')) {
    _loadPersistedLocale();
  }

  void _loadPersistedLocale() {
    final langCode = _hiveStorage.get<String>(
      HiveStorageService.boxSettings,
      _keyLanguageCode,
      defaultValue: 'ar',
    );
    emit(Locale(langCode ?? 'ar'));
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _hiveStorage.put(
      HiveStorageService.boxSettings,
      _keyLanguageCode,
      locale.languageCode,
    );
  }

  Future<void> toggleLocale() async {
    final nextCode = state.languageCode == 'ar' ? 'en' : 'ar';
    await setLocale(Locale(nextCode));
  }
}
