import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vpn_bloc.dart';
import '../bloc/vpn_event.dart';
import '../bloc/vpn_state.dart';
import '../models/vpn_status.dart';
import '../models/vpn_server.dart';
import 'country_selection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildAppBar(context),
                const SizedBox(height: 40),
                Expanded(
                  child: BlocBuilder<VpnBloc, VpnState>(
                    builder: (context, state) {
                      if (state is VpnServersLoading) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Loading VPN servers...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is VpnServersLoadError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Failed to load VPN servers',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  state.error,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<VpnBloc>().add(const LoadVpnServers());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF6366F1),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is VpnStateLoaded) {
                        return _buildVpnContent(context, state.vpnStatus, state.selectedServer);
                      }
                      
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 28,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'VPN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildVpnContent(BuildContext context, VpnStatus vpnStatus, VpnServer? selectedServer) {
    return Column(
      children: [
        _buildConnectionButton(context, vpnStatus),
        const SizedBox(height: 30),
        _buildStatusText(vpnStatus),
        const SizedBox(height: 40),
        _buildSpeedInfo(vpnStatus),
        const SizedBox(height: 40),
        _buildLocationSection(context, vpnStatus),
        const Spacer(),
        _buildServerSelector(context, selectedServer),
      ],
    );
  }

  Widget _buildConnectionButton(BuildContext context, VpnStatus vpnStatus) {
    final isConnected = vpnStatus.status == VpnConnectionStatus.connected;
    final isConnecting = vpnStatus.status == VpnConnectionStatus.connecting;
    final isDisconnecting = vpnStatus.status == VpnConnectionStatus.disconnecting;

    return GestureDetector(
      onTap: () {
        if (isConnected) {
          context.read<VpnBloc>().add(const DisconnectVpn());
        } else if (!isConnecting && !isDisconnecting) {
          context.read<VpnBloc>().add(const ConnectVpn());
        }
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: isConnecting || isDisconnecting
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                )
              : Icon(
                  Icons.power_settings_new,
                  size: 80,
                  color: isConnected ? Colors.green : const Color(0xFF6366F1),
                ),
        ),
      ),
    );
  }

  Widget _buildStatusText(VpnStatus vpnStatus) {
    String statusText;
    Color statusColor;

    switch (vpnStatus.status) {
      case VpnConnectionStatus.connected:
        statusText = 'Connected';
        statusColor = Colors.green;
        break;
      case VpnConnectionStatus.connecting:
        statusText = 'Connecting...';
        statusColor = Colors.orange;
        break;
      case VpnConnectionStatus.disconnecting:
        statusText = 'Disconnecting...';
        statusColor = Colors.orange;
        break;
      case VpnConnectionStatus.disconnected:
      default:
        statusText = 'Disconnected';
        statusColor = Colors.red;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedInfo(VpnStatus vpnStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Text(
            'Speed',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedItem(
                'Download',
                vpnStatus.downloadSpeed.toStringAsFixed(1),
                Colors.blue,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white30,
              ),
              _buildSpeedItem(
                'Upload',
                vpnStatus.uploadSpeed.toStringAsFixed(1),
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedItem(String label, String speed, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          speed,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'mbps',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context, VpnStatus vpnStatus) {
    return Column(
      children: [
        const Text(
          'Location',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Text(
              '🗺️',
              style: TextStyle(fontSize: 60),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildServerSelector(BuildContext context, VpnServer? selectedServer) {
    if (selectedServer == null) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CountrySelectionScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.public,
                color: Color(0xFF6366F1),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Select Server',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF6366F1),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CountrySelectionScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedServer.flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedServer.countryLong,
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${selectedServer.ping}ms • ${selectedServer.speedInMbps.toStringAsFixed(1)} Mbps',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }
}