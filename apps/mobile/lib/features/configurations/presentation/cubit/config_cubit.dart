import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/configuration_entity.dart';
import '../../domain/repositories/configuration_repository.dart';

abstract class ConfigState extends Equatable {
  const ConfigState();

  @override
  List<Object?> get props => [];
}

class ConfigInitial extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final List<ConfigurationEntity> localConfigs;
  final List<ConfigurationEntity> communityConfigs;
  final ConfigurationEntity? selectedConfig;
  final bool isImporting;
  final bool isSharing;
  final String? lastGeneratedShareCode;

  const ConfigLoaded({
    required this.localConfigs,
    this.communityConfigs = const [],
    this.selectedConfig,
    this.isImporting = false,
    this.isSharing = false,
    this.lastGeneratedShareCode,
  });

  ConfigLoaded copyWith({
    List<ConfigurationEntity>? localConfigs,
    List<ConfigurationEntity>? communityConfigs,
    ConfigurationEntity? selectedConfig,
    bool clearSelected = false,
    bool? isImporting,
    bool? isSharing,
    String? lastGeneratedShareCode,
  }) {
    return ConfigLoaded(
      localConfigs: localConfigs ?? this.localConfigs,
      communityConfigs: communityConfigs ?? this.communityConfigs,
      selectedConfig: clearSelected ? null : (selectedConfig ?? this.selectedConfig),
      isImporting: isImporting ?? this.isImporting,
      isSharing: isSharing ?? this.isSharing,
      lastGeneratedShareCode: lastGeneratedShareCode,
    );
  }

  @override
  List<Object?> get props => [
        localConfigs,
        communityConfigs,
        selectedConfig,
        isImporting,
        isSharing,
        lastGeneratedShareCode,
      ];
}

class ConfigError extends ConfigState {
  final String message;

  const ConfigError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConfigCubit extends Cubit<ConfigState> {
  final IConfigurationRepository _repository;

  ConfigCubit(this._repository) : super(ConfigInitial());

  Future<void> loadConfigs() async {
    emit(ConfigLoading());

    final localResult = await _repository.getLocalConfigurations();
    final communityResult = await _repository.getCommunityConfigurations();

    localResult.fold(
      (failure) => emit(ConfigError(failure.message)),
      (local) {
        final community = communityResult.getOrElse((_) => []);
        emit(ConfigLoaded(
          localConfigs: local,
          communityConfigs: community,
          selectedConfig: local.isNotEmpty ? local.first : null,
        ));
      },
    );
  }

  void selectConfig(ConfigurationEntity? config) {
    if (state is ConfigLoaded) {
      final current = state as ConfigLoaded;
      emit(current.copyWith(selectedConfig: config));
    }
  }

  Future<bool> importFromRaw(String text, {String? name}) async {
    if (state is ConfigLoaded) {
      final current = state as ConfigLoaded;
      emit(current.copyWith(isImporting: true));

      final result = await _repository.importFromRawString(text, name: name);
      return result.fold(
        (failure) {
          emit(ConfigError(failure.message));
          return false;
        },
        (newConfig) {
          final updated = List<ConfigurationEntity>.from(current.localConfigs)..add(newConfig);
          emit(current.copyWith(
            localConfigs: updated,
            selectedConfig: newConfig,
            isImporting: false,
          ));
          return true;
        },
      );
    }
    return false;
  }

  Future<bool> importByCode(String code) async {
    if (state is ConfigLoaded) {
      final current = state as ConfigLoaded;
      emit(current.copyWith(isImporting: true));

      final result = await _repository.importByShareCode(code);
      return result.fold(
        (failure) {
          emit(ConfigError(failure.message));
          return false;
        },
        (newConfig) {
          final updated = List<ConfigurationEntity>.from(current.localConfigs)..add(newConfig);
          emit(current.copyWith(
            localConfigs: updated,
            selectedConfig: newConfig,
            isImporting: false,
          ));
          return true;
        },
      );
    }
    return false;
  }

  Future<String?> shareConfig(ConfigurationEntity config) async {
    if (state is ConfigLoaded) {
      final current = state as ConfigLoaded;
      emit(current.copyWith(isSharing: true));

      final result = await _repository.shareConfiguration(config);
      return result.fold(
        (failure) {
          emit(ConfigError(failure.message));
          return null;
        },
        (shareCode) {
          emit(current.copyWith(
            isSharing: false,
            lastGeneratedShareCode: shareCode,
          ));
          return shareCode;
        },
      );
    }
    return null;
  }

  Future<void> deleteConfig(int id) async {
    if (state is ConfigLoaded) {
      final current = state as ConfigLoaded;
      final result = await _repository.deleteConfiguration(id);

      result.fold(
        (failure) => emit(ConfigError(failure.message)),
        (_) {
          final updated = current.localConfigs.where((c) => c.id != id).toList();
          final newSelected = current.selectedConfig?.id == id
              ? (updated.isNotEmpty ? updated.first : null)
              : current.selectedConfig;

          emit(current.copyWith(
            localConfigs: updated,
            selectedConfig: newSelected,
            clearSelected: newSelected == null,
          ));
        },
      );
    }
  }

  Future<void> toggleFavorite(ConfigurationEntity config) async {
    if (config.id == null) return;
    final toggled = config.copyWith(isFavorite: !config.isFavorite);
    final result = await _repository.saveConfiguration(toggled);

    result.fold(
      (failure) => emit(ConfigError(failure.message)),
      (saved) {
        if (state is ConfigLoaded) {
          final current = state as ConfigLoaded;
          final updated = current.localConfigs.map((c) => c.id == saved.id ? saved : c).toList();
          emit(current.copyWith(localConfigs: updated));
        }
      },
    );
  }
}
