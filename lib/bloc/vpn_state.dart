import 'package:equatable/equatable.dart';
import '../models/vpn_status.dart';
import '../models/vpn_server.dart';
import '../models/vpn_protocol.dart';

abstract class VpnState extends Equatable {
  const VpnState();

  @override
  List<Object?> get props => [];
}

class VpnInitial extends VpnState {
  const VpnInitial();
}

class VpnServersLoading extends VpnState {
  const VpnServersLoading();
}

class VpnServersLoadError extends VpnState {
  final String error;

  const VpnServersLoadError(this.error);

  @override
  List<Object?> get props => [error];
}

class VpnStateLoaded extends VpnState {
  final VpnStatus vpnStatus;
  final List<VpnServer> availableServers;
  final VpnServer? selectedServer;
  final VpnProtocol selectedProtocol;

  const VpnStateLoaded({
    required this.vpnStatus,
    required this.availableServers,
    this.selectedServer,
    this.selectedProtocol = VpnProtocol.openVpn,
  });

  @override
  List<Object?> get props => [vpnStatus, availableServers, selectedServer, selectedProtocol];

  VpnStateLoaded copyWith({
    VpnStatus? vpnStatus,
    List<VpnServer>? availableServers,
    VpnServer? selectedServer,
    VpnProtocol? selectedProtocol,
  }) {
    return VpnStateLoaded(
      vpnStatus: vpnStatus ?? this.vpnStatus,
      availableServers: availableServers ?? this.availableServers,
      selectedServer: selectedServer ?? this.selectedServer,
      selectedProtocol: selectedProtocol ?? this.selectedProtocol,
    );
  }
}