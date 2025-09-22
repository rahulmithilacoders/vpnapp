import 'package:equatable/equatable.dart';
import '../models/vpn_server.dart';
import '../models/vpn_protocol.dart';
import '../models/vpn_status.dart';

abstract class VpnEvent extends Equatable {
  const VpnEvent();

  @override
  List<Object?> get props => [];
}

class LoadVpnServers extends VpnEvent {
  const LoadVpnServers();
}

class ConnectVpn extends VpnEvent {
  const ConnectVpn();
}

class DisconnectVpn extends VpnEvent {
  const DisconnectVpn();
}

class SelectServer extends VpnEvent {
  final VpnServer server;

  const SelectServer(this.server);

  @override
  List<Object?> get props => [server];
}

class SelectCountry extends VpnEvent {
  final String countryCode;
  final String countryName;

  const SelectCountry({
    required this.countryCode,
    required this.countryName,
  });

  @override
  List<Object?> get props => [countryCode, countryName];
}

class UpdateSpeed extends VpnEvent {
  final double downloadSpeed;
  final double uploadSpeed;

  const UpdateSpeed({
    required this.downloadSpeed,
    required this.uploadSpeed,
  });

  @override
  List<Object?> get props => [downloadSpeed, uploadSpeed];
}

class UpdateLocation extends VpnEvent {
  final String ipAddress;
  final String location;

  const UpdateLocation({
    required this.ipAddress,
    required this.location,
  });

  @override
  List<Object?> get props => [ipAddress, location];
}

class SelectProtocol extends VpnEvent {
  final VpnProtocol protocol;

  const SelectProtocol(this.protocol);

  @override
  List<Object?> get props => [protocol];
}

class UpdateVpnStatus extends VpnEvent {
  final VpnConnectionStatus status;

  const UpdateVpnStatus(this.status);

  @override
  List<Object?> get props => [status];
}