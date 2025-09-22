import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vpn_bloc.dart';
import '../bloc/vpn_event.dart';
import '../models/vpn_protocol.dart';

class ProtocolSelectionScreen extends StatelessWidget {
  const ProtocolSelectionScreen({super.key});

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
                child: _buildProtocolList(context),
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
                'Choose VPN Protocol',
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

  Widget _buildProtocolList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: VpnProtocol.values.length,
          itemBuilder: (context, index) {
            final protocol = VpnProtocol.values[index];
            return _buildProtocolItem(context, protocol);
          },
        ),
      ),
    );
  }

  Widget _buildProtocolItem(BuildContext context, VpnProtocol protocol) {
    return InkWell(
      onTap: () {
        context.read<VpnBloc>().add(SelectProtocol(protocol));
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: _getProtocolColor(protocol).withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  _getProtocolIcon(protocol),
                  color: _getProtocolColor(protocol),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    protocol.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    protocol.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: protocol.supportedPlatforms.take(3).map((platform) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          platform,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: protocol.requiresClient 
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    protocol.requiresClient ? 'Client Required' : 'No Client',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: protocol.requiresClient ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ports: ${protocol.defaultPorts.take(2).join(', ')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
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
}