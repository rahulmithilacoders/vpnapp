import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vpn_bloc.dart';
import '../bloc/vpn_state.dart';
import '../models/vpn_protocol.dart';
import 'ip_test_screen.dart';
import 'speed_test_screen.dart';
import 'protocol_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildSettingsList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BlocBuilder<VpnBloc, VpnState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildProtocolSettingsItem(context, state),
                _buildSettingsItem(
              context,
              icon: Icons.speed,
              title: 'Speed Test',
              subtitle: 'Test your internet connection speed',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SpeedTestScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              context,
              icon: Icons.public,
              title: 'IP Test',
              subtitle: 'Check your current IP address',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const IpTestScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App information and version',
              onTap: () {},
            ),
            _buildSettingsItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {},
            ),
            _buildSettingsItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {},
            ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProtocolSettingsItem(BuildContext context, VpnState state) {
    VpnProtocol selectedProtocol = VpnProtocol.openVpn;
    if (state is VpnStateLoaded) {
      selectedProtocol = state.selectedProtocol;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProtocolSelectionScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _getProtocolColor(selectedProtocol).withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  _getProtocolIcon(selectedProtocol),
                  color: _getProtocolColor(selectedProtocol),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VPN Protocol',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Current: ${selectedProtocol.displayName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Color _getProtocolColor(VpnProtocol protocol) {
    switch (protocol) {
      case VpnProtocol.openVpn:
        return Colors.blue;
      case VpnProtocol.sslVpn:
        return Colors.green;
      case VpnProtocol.l2tpIpsec:
        return Colors.orange;
      case VpnProtocol.msSstp:
        return Colors.purple;
    }
  }

  IconData _getProtocolIcon(VpnProtocol protocol) {
    switch (protocol) {
      case VpnProtocol.openVpn:
        return Icons.vpn_key;
      case VpnProtocol.sslVpn:
        return Icons.security;
      case VpnProtocol.l2tpIpsec:
        return Icons.shield;
      case VpnProtocol.msSstp:
        return Icons.verified_user;
    }
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6366F1),
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}