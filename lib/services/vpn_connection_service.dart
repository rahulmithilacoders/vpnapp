import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_vpn_plugin/flutter_vpn_plugin.dart' as vpn_plugin;
import '../models/vpn_server.dart';
import '../models/vpn_status.dart';
import '../models/vpn_protocol.dart';
import '../services/vpn_gate_service.dart';

class VpnConnectionService {
  static final VpnConnectionService _instance = VpnConnectionService._internal();
  factory VpnConnectionService() => _instance;
  VpnConnectionService._internal();

  StreamSubscription<vpn_plugin.VpnStatus>? _statusSubscription;
  final StreamController<VpnConnectionStatus> _statusController = StreamController<VpnConnectionStatus>.broadcast();

  Stream<VpnConnectionStatus> get statusStream => _statusController.stream;

  Future<bool> checkVpnPermission() async {
    try {
      return await vpn_plugin.FlutterVpnPlugin.isPermissionGranted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestVpnPermission() async {
    try {
      return await vpn_plugin.FlutterVpnPlugin.requestPermission();
    } catch (e) {
      return false;
    }
  }

  Future<bool> isVpnSupported() async {
    try {
      return await vpn_plugin.FlutterVpnPlugin.isSupported;
    } catch (e) {
      return false;
    }
  }

  Future<void> connectToServer(VpnServer server, {VpnProtocol protocol = VpnProtocol.openVpn}) async {
    try {
      // Check VPN support first
      bool isSupported = await isVpnSupported();
      if (!isSupported) {
        throw Exception('VPN not supported on this device');
      }

      // Check permission
      bool hasPermission = await checkVpnPermission();
      if (!hasPermission) {
        hasPermission = await requestVpnPermission();
        if (!hasPermission) {
          throw Exception('VPN permission denied');
        }
      }

      // Decode OpenVPN config
      String ovpnConfig = '';
      if (server.openVpnConfigDataBase64.isNotEmpty) {
        try {
          ovpnConfig = VpnGateService.decodeOpenVpnConfig(server.openVpnConfigDataBase64);
        } catch (e) {
          debugPrint('Failed to decode OpenVPN config: $e');
        }
      }

      // Get credentials
      final credentials = VpnGateService.getVpnCredentials();

      // Get default port for the selected protocol
      final defaultPort = protocol.defaultPorts.first;
      
      // Create VPN config with protocol-specific parameters
      final config = vpn_plugin.VpnConfig(
        serverHost: server.ip,
        serverPort: defaultPort,
        username: credentials['username']!,
        password: credentials['password']!,
        ovpnConfig: ovpnConfig,
        protocol: protocol.protocolId, // Add protocol parameter
      );

      // Start listening to status updates before connecting
      _startStatusListener();

      // Update status to connecting
      _statusController.add(VpnConnectionStatus.connecting);

      // Connect to VPN with retry logic
      await _connectWithRetry(config, maxRetries: 3);

    } catch (e) {
      _statusController.add(VpnConnectionStatus.error);
      rethrow;
    }
  }

  Future<void> _connectWithRetry(vpn_plugin.VpnConfig config, {int maxRetries = 3}) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        attempts++;
        debugPrint('VPN connection attempt $attempts/$maxRetries to ${config.serverHost}:${config.serverPort}');
        await vpn_plugin.FlutterVpnPlugin.connect(config);
        debugPrint('VPN connection successful on attempt $attempts');
        return; // Success
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('VPN connection attempt $attempts failed: $e');
        
        if (attempts < maxRetries) {
          debugPrint('Waiting 3 seconds before retry...');
          await Future.delayed(Duration(seconds: 3)); // Longer wait before retry
        }
      }
    }

    throw lastException ?? Exception('Failed to connect after $maxRetries attempts');
  }

  Future<void> disconnect() async {
    try {
      _statusController.add(VpnConnectionStatus.disconnecting);
      await vpn_plugin.FlutterVpnPlugin.disconnect();
      await vpn_plugin.FlutterVpnPlugin.stopVpnService();
      _statusController.add(VpnConnectionStatus.disconnected);
    } catch (e) {
      _statusController.add(VpnConnectionStatus.error);
      rethrow;
    }
  }

  Future<VpnConnectionStatus> getCurrentStatus() async {
    try {
      final status = await vpn_plugin.FlutterVpnPlugin.getStatus();
      return _mapVpnState(status.state);
    } catch (e) {
      return VpnConnectionStatus.disconnected;
    }
  }

  void _startStatusListener() {
    _statusSubscription?.cancel();
    _statusSubscription = vpn_plugin.FlutterVpnPlugin.statusStream.listen(
      (vpnStatus) {
        final status = _mapVpnState(vpnStatus.state);
        _statusController.add(status);
        
        // Log status changes for debugging
        debugPrint('VPN Status: ${vpnStatus.state} -> $status');
        if (vpnStatus.message != null) {
          debugPrint('VPN Message: ${vpnStatus.message}');
        }
      },
      onError: (error) {
        debugPrint('VPN Status Error: $error');
        _statusController.add(VpnConnectionStatus.error);
      },
    );
  }

  VpnConnectionStatus _mapVpnState(vpn_plugin.VpnConnectionState state) {
    switch (state) {
      case vpn_plugin.VpnConnectionState.disconnected:
        return VpnConnectionStatus.disconnected;
      case vpn_plugin.VpnConnectionState.connecting:
        return VpnConnectionStatus.connecting;
      case vpn_plugin.VpnConnectionState.connected:
        return VpnConnectionStatus.connected;
      case vpn_plugin.VpnConnectionState.disconnecting:
        return VpnConnectionStatus.disconnecting;
      case vpn_plugin.VpnConnectionState.error:
        return VpnConnectionStatus.error;
    }
  }

  Future<void> stopVpnService() async {
    try {
      await vpn_plugin.FlutterVpnPlugin.stopVpnService();
    } catch (e) {
      // Ignore stop errors
    }
  }

  void dispose() {
    _statusSubscription?.cancel();
    _statusController.close();
  }
}