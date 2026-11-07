import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/hive_storage_service.dart';
import 'app_colors.dart';

class ThemeState {
  final ThemeMode mode;
  final ThemePreset preset;
  final Color customSeedColor;

  const ThemeState({
    required this.mode,
    required this.preset,
    required this.customSeedColor,
  });

  Color get activeSeedColor => preset.seedColor;

  ThemeState copyWith({
    ThemeMode? mode,
    ThemePreset? preset,
    Color? customSeedColor,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      preset: preset ?? this.preset,
      customSeedColor: customSeedColor ?? this.customSeedColor,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  final IHiveStorageService _hiveStorage;

  static const String _keyThemeMode = 'theme_mode';
  static const String _keyThemePreset = 'theme_preset';

  ThemeCubit(this._hiveStorage)
      : super(const ThemeState(
          mode: ThemeMode.system,
          preset: ThemePreset.green,
          customSeedColor: Color(0xFF087f5b),
        )) {
    _loadPersistedTheme();
  }

  void _loadPersistedTheme() {
    final modeIndex = _hiveStorage.get<int>(
      HiveStorageService.boxSettings,
      _keyThemeMode,
      defaultValue: ThemeMode.system.index,
    );
    final presetIndex = _hiveStorage.get<int>(
      HiveStorageService.boxSettings,
      _keyThemePreset,
      defaultValue: ThemePreset.green.index,
    );

    emit(state.copyWith(
      mode: ThemeMode.values[modeIndex ?? ThemeMode.system.index],
      preset: ThemePreset.values[presetIndex ?? ThemePreset.green.index],
    ));
    
    // Initialize dynamic colors based on loaded theme mode (alahisan style)
    final isDark = state.mode == ThemeMode.dark ||
        (state.mode == ThemeMode.system &&
            PlatformDispatcher.instance.platformBrightness == Brightness.dark);
    AppColors.updateDynamicColors(isDark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await _hiveStorage.put(
      HiveStorageService.boxSettings,
      _keyThemeMode,
      mode.index,
    );
    // Update dynamic colors based on dark mode (alahisan style)
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            PlatformDispatcher.instance.platformBrightness == Brightness.dark);
    AppColors.updateDynamicColors(isDark);
  }

  Future<void> setPreset(ThemePreset preset) async {
    emit(state.copyWith(preset: preset));
    await _hiveStorage.put(
      HiveStorageService.boxSettings,
      _keyThemePreset,
      preset.index,
    );
  }
}
