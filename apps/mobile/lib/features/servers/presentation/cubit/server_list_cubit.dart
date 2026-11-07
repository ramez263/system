import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/server_entity.dart';
import '../../domain/repositories/server_repository.dart';

abstract class ServerListState extends Equatable {
  const ServerListState();

  @override
  List<Object?> get props => [];
}

class ServerListInitial extends ServerListState {}

class ServerListLoading extends ServerListState {}

class ServerListLoaded extends ServerListState {
  final List<ServerEntity> servers;
  final List<ServerEntity> filteredServers;
  final ServerEntity? selectedServer;
  final String? selectedCountry;
  final String searchQuery;
  final bool isOffline;

  const ServerListLoaded({
    required this.servers,
    required this.filteredServers,
    this.selectedServer,
    this.selectedCountry,
    this.searchQuery = '',
    this.isOffline = false,
  });

  ServerListLoaded copyWith({
    List<ServerEntity>? servers,
    List<ServerEntity>? filteredServers,
    ServerEntity? selectedServer,
    String? selectedCountry,
    String? searchQuery,
    bool? isOffline,
  }) {
    return ServerListLoaded(
      servers: servers ?? this.servers,
      filteredServers: filteredServers ?? this.filteredServers,
      selectedServer: selectedServer ?? this.selectedServer,
      selectedCountry: selectedCountry != null 
          ? (selectedCountry == 'ALL' ? null : selectedCountry) 
          : this.selectedCountry,
      searchQuery: searchQuery ?? this.searchQuery,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        servers,
        filteredServers,
        selectedServer,
        selectedCountry,
        searchQuery,
        isOffline,
      ];
}

class ServerListError extends ServerListState {
  final String message;

  const ServerListError(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerListCubit extends Cubit<ServerListState> {
  final IServerRepository _serverRepository;

  ServerListCubit(this._serverRepository) : super(ServerListInitial());

  Future<void> loadServers({bool forceRefresh = false}) async {
    if (state is! ServerListLoaded || forceRefresh) {
      emit(ServerListLoading());
    }

    final result = await _serverRepository.getServers();
    result.fold(
      (failure) => emit(ServerListError(failure.message)),
      (servers) {
        final currentSelected = state is ServerListLoaded 
            ? (state as ServerListLoaded).selectedServer 
            : null;

        final selected = currentSelected ?? (servers.isNotEmpty ? servers.first : null);

        emit(ServerListLoaded(
          servers: servers,
          filteredServers: servers,
          selectedServer: selected,
        ));
      },
    );
  }

  void selectServer(ServerEntity server) {
    if (state is ServerListLoaded) {
      final current = state as ServerListLoaded;
      emit(current.copyWith(selectedServer: server));
    }
  }

  void filterByCountry(String? countryCode) {
    if (state is ServerListLoaded) {
      final current = state as ServerListLoaded;
      final country = (countryCode == null || countryCode == 'ALL') ? null : countryCode;
      
      final filtered = _applyFilters(current.servers, country, current.searchQuery);
      emit(current.copyWith(
        selectedCountry: countryCode ?? 'ALL',
        filteredServers: filtered,
      ));
    }
  }

  void search(String query) {
    if (state is ServerListLoaded) {
      final current = state as ServerListLoaded;
      final filtered = _applyFilters(current.servers, current.selectedCountry, query);
      emit(current.copyWith(
        searchQuery: query,
        filteredServers: filtered,
      ));
    }
  }

  void autoSelectBestServer() {
    if (state is ServerListLoaded) {
      final current = state as ServerListLoaded;
      if (current.servers.isEmpty) return;

      // Score by ping (weight 70%) and load (weight 30%)
      final sorted = List<ServerEntity>.from(current.servers)
        ..sort((a, b) {
          final scoreA = (a.pingMs * 0.7) + (a.currentLoad * 0.3);
          final scoreB = (b.pingMs * 0.7) + (b.currentLoad * 0.3);
          return scoreA.compareTo(scoreB);
        });

      emit(current.copyWith(selectedServer: sorted.first));
    }
  }

  List<ServerEntity> _applyFilters(List<ServerEntity> all, String? country, String query) {
    var result = all;
    if (country != null && country.isNotEmpty && country != 'ALL') {
      result = result.where((s) => s.countryCode.toUpperCase() == country.toUpperCase()).toList();
    }
    if (query.trim().isNotEmpty) {
      final term = query.toLowerCase().trim();
      result = result.where((s) =>
          s.name.toLowerCase().contains(term) ||
          s.countryName.toLowerCase().contains(term) ||
          (s.city != null && s.city!.toLowerCase().contains(term))).toList();
    }
    return result;
  }
}
