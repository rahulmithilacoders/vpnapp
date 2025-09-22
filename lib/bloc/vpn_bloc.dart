import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../models/vpn_status.dart' as models;
import '../models/vpn_server.dart';
import '../services/vpn_gate_service.dart';
import '../services/vpn_connection_service.dart';
import 'vpn_event.dart';
import 'vpn_state.dart';

class VpnBloc extends Bloc<VpnEvent, VpnState> {
  final VpnConnectionService _vpnService = VpnConnectionService();
  StreamSubscription<models.VpnConnectionStatus>? _vpnStatusSubscription;

  VpnBloc() : super(const VpnInitial()) {
    on<LoadVpnServers>(_onLoadVpnServers);
    on<ConnectVpn>(_onConnectVpn);
    on<DisconnectVpn>(_onDisconnectVpn);
    on<SelectServer>(_onSelectServer);
    on<SelectCountry>(_onSelectCountry);
    on<SelectProtocol>(_onSelectProtocol);
    on<UpdateVpnStatus>(_onUpdateVpnStatus);
    on<UpdateSpeed>(_onUpdateSpeed);
    on<UpdateLocation>(_onUpdateLocation);

    _startVpnStatusListener();
    add(const LoadVpnServers());
  }

  models.VpnStatus get currentVpnStatus {
    final state = this.state;
    if (state is VpnStateLoaded) {
      return state.vpnStatus;
    }
    return const models.VpnStatus(status: models.VpnConnectionStatus.disconnected);
  }

  List<VpnServer> get availableServers {
    final state = this.state;
    if (state is VpnStateLoaded) {
      return state.availableServers;
    }
    return [];
  }

  VpnServer? get selectedServer {
    final state = this.state;
    if (state is VpnStateLoaded) {
      return state.selectedServer;
    }
    return null;
  }

  Future<void> _onLoadVpnServers(LoadVpnServers event, Emitter<VpnState> emit) async {
    emit(const VpnServersLoading());
    
    try {
      final servers = await VpnGateService.fetchVpnServers();
      
      if (servers.isNotEmpty) {
        final defaultServer = servers.first;
        
        emit(VpnStateLoaded(
          vpnStatus: models.VpnStatus(
            status: models.VpnConnectionStatus.disconnected,
            selectedCountryCode: defaultServer.countryShort,
            selectedCountryName: defaultServer.countryLong,
          ),
          availableServers: servers,
          selectedServer: defaultServer,
        ));
      } else {
        emit(const VpnServersLoadError('No VPN servers available'));
      }
    } catch (e) {
      emit(VpnServersLoadError('Failed to load VPN servers: $e'));
    }
  }

  Future<void> _onConnectVpn(ConnectVpn event, Emitter<VpnState> emit) async {
    final currentState = state;
    if (currentState is! VpnStateLoaded) return;

    final currentStatus = currentState.vpnStatus;
    final selectedServer = currentState.selectedServer;
    
    if (selectedServer == null) {
      debugPrint('No server selected for connection');
      return;
    }

    try {
      debugPrint('Attempting to connect to selected server: ${selectedServer.hostName} (${selectedServer.countryLong})');
      
      emit(currentState.copyWith(
        vpnStatus: currentStatus.copyWith(
          status: models.VpnConnectionStatus.connecting,
          selectedCountryCode: selectedServer.countryShort,
          selectedCountryName: selectedServer.countryLong,
        ),
      ));

      // Connect to the selected server with the selected protocol
      await _vpnService.connectToServer(selectedServer, protocol: currentState.selectedProtocol);
      debugPrint('Successfully connected to ${selectedServer.hostName} using ${currentState.selectedProtocol.displayName}');

    } catch (e) {
      debugPrint('Failed to connect to ${selectedServer.hostName}: $e');
      
      emit(currentState.copyWith(
        vpnStatus: currentStatus.copyWith(
          status: models.VpnConnectionStatus.error,
        ),
      ));
      
      // Wait a moment then reset to disconnected
      await Future.delayed(Duration(seconds: 2));
      emit(currentState.copyWith(
        vpnStatus: currentStatus.copyWith(
          status: models.VpnConnectionStatus.disconnected,
        ),
      ));
    }
  }

  Future<void> _onDisconnectVpn(DisconnectVpn event, Emitter<VpnState> emit) async {
    final currentState = state;
    if (currentState is! VpnStateLoaded) return;

    final currentStatus = currentState.vpnStatus;
    
    try {
      emit(currentState.copyWith(
        vpnStatus: currentStatus.copyWith(
          status: models.VpnConnectionStatus.disconnecting,
        ),
      ));

      // Disconnect from VPN using the real service
      await _vpnService.disconnect();

    } catch (e) {
      emit(currentState.copyWith(
        vpnStatus: currentStatus.copyWith(
          status: models.VpnConnectionStatus.disconnected,
        ),
      ));
    }
  }

  Future<void> _onSelectServer(SelectServer event, Emitter<VpnState> emit) async {
    final currentState = state;
    if (currentState is! VpnStateLoaded) return;

    final currentStatus = currentState.vpnStatus;
    
    emit(currentState.copyWith(
      vpnStatus: currentStatus.copyWith(
        selectedCountryCode: event.server.countryShort,
        selectedCountryName: event.server.countryLong,
      ),
      selectedServer: event.server,
    ));
  }

  Future<void> _onSelectCountry(SelectCountry event, Emitter<VpnState> emit) async {
    final currentState = state;
    if (currentState is! VpnStateLoaded) return;

    try {
      final server = await VpnGateService.getBestServerForCountry(event.countryCode);
      if (server != null) {
        add(SelectServer(server));
      }
    } catch (e) {
      final currentStatus = currentState.vpnStatus;
      emit(currentState.copyWith(
        vpnStatus: currentStatus.copyWith(
          selectedCountryCode: event.countryCode,
          selectedCountryName: event.countryName,
        ),
      ));
    }
  }

  Future<void> _onSelectProtocol(SelectProtocol event, Emitter<VpnState> emit) async {
    final currentState = state;
    if (currentState is! VpnStateLoaded) return;
    
    emit(currentState.copyWith(selectedProtocol: event.protocol));
  }

  void _onUpdateVpnStatus(UpdateVpnStatus event, Emitter<VpnState> emit) {
    final currentState = state;
    if (currentState is! VpnStateLoaded) return;

    final newStatus = event.status;
    debugPrint('VPN BLoC: Status change to $newStatus');
    
    // Update the main VPN status
    final updatedStatus = currentState.vpnStatus.copyWith(
      status: newStatus,
      downloadSpeed: newStatus == models.VpnConnectionStatus.connected ? 
        currentState.selectedServer?.speedInMbps ?? 0.0 : 0.0,
      uploadSpeed: newStatus == models.VpnConnectionStatus.connected ? 
        (currentState.selectedServer?.speedInMbps ?? 0.0) * 0.7 : 0.0,
      ipAddress: newStatus == models.VpnConnectionStatus.connected && currentState.selectedServer != null ?
        currentState.selectedServer!.ip : null,
      location: newStatus == models.VpnConnectionStatus.connected && currentState.selectedServer != null ?
        currentState.selectedServer!.countryLong : null,
    );
    
    emit(currentState.copyWith(vpnStatus: updatedStatus));
  }

  void _onUpdateSpeed(UpdateSpeed event, Emitter<VpnState> emit) {
    final currentState = state;
    if (currentState is! VpnStateLoaded) return;

    final currentStatus = currentState.vpnStatus;
    
    emit(currentState.copyWith(
      vpnStatus: currentStatus.copyWith(
        downloadSpeed: event.downloadSpeed,
        uploadSpeed: event.uploadSpeed,
      ),
    ));
  }

  void _onUpdateLocation(UpdateLocation event, Emitter<VpnState> emit) {
    final currentState = state;
    if (currentState is! VpnStateLoaded) return;

    final currentStatus = currentState.vpnStatus;
    
    emit(currentState.copyWith(
      vpnStatus: currentStatus.copyWith(
        ipAddress: event.ipAddress,
        location: event.location,
      ),
    ));
  }

  void _startVpnStatusListener() {
    _vpnStatusSubscription = _vpnService.statusStream.listen((status) {
      final newStatus = _mapConnectionStatus(status);
      add(UpdateVpnStatus(newStatus));
    });
  }

  models.VpnConnectionStatus _mapConnectionStatus(models.VpnConnectionStatus serviceStatus) {
    return serviceStatus;
  }

  @override
  Future<void> close() {
    _vpnStatusSubscription?.cancel();
    _vpnService.dispose();
    return super.close();
  }
}