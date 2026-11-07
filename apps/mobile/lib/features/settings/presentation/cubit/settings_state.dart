import 'package:equatable/equatable.dart';
import '../../domain/entities/advanced_network_settings.dart';
import '../../domain/entities/app_settings_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AdvancedNetworkSettings advancedSettings;
  final AppSettingsEntity appSettings;
  final String? feedbackMessage;

  const SettingsLoaded({
    required this.advancedSettings,
    required this.appSettings,
    this.feedbackMessage,
  });

  SettingsLoaded copyWith({
    AdvancedNetworkSettings? advancedSettings,
    AppSettingsEntity? appSettings,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return SettingsLoaded(
      advancedSettings: advancedSettings ?? this.advancedSettings,
      appSettings: appSettings ?? this.appSettings,
      feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }

  @override
  List<Object?> get props => [advancedSettings, appSettings, feedbackMessage];
}
