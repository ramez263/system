import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/device_profile.dart';
import '../../domain/repositories/auth_repository.dart';

abstract class DeviceAuthState extends Equatable {
  const DeviceAuthState();

  @override
  List<Object?> get props => [];
}

class DeviceAuthInitial extends DeviceAuthState {}

class DeviceAuthLoading extends DeviceAuthState {}

class DeviceAuthAuthenticated extends DeviceAuthState {
  final DeviceProfile profile;

  const DeviceAuthAuthenticated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DeviceAuthError extends DeviceAuthState {
  final String message;

  const DeviceAuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeviceAuthCubit extends Cubit<DeviceAuthState> {
  final IAuthRepository _authRepository;

  DeviceAuthCubit(this._authRepository) : super(DeviceAuthInitial());

  Future<void> initHandshake() async {
    emit(DeviceAuthLoading());
    final result = await _authRepository.performHandshake();
    result.fold(
      (failure) => emit(DeviceAuthError(failure.message)),
      (profile) => emit(DeviceAuthAuthenticated(profile)),
    );
  }

  Future<void> refreshProfile() async {
    final result = await _authRepository.getDeviceProfile();
    result.fold(
      (failure) => emit(DeviceAuthError(failure.message)),
      (profile) => emit(DeviceAuthAuthenticated(profile)),
    );
  }
}
