enum VpnProtocol {
  openVpn('OpenVPN', 'Open source VPN protocol', ['Windows', 'Mac', 'iPhone', 'Android']),
  sslVpn('SSL-VPN', 'Secure Socket Layer VPN', ['Windows', 'Comfortable']),
  l2tpIpsec('L2TP/IPsec', 'Layer 2 Tunneling Protocol with IPsec', ['Windows', 'Mac', 'iPhone', 'Android']),
  msSstp('MS-SSTP', 'Microsoft Secure Socket Tunneling Protocol', ['Windows Vista', '7', '8', 'RT']);

  const VpnProtocol(this.displayName, this.description, this.supportedPlatforms);

  final String displayName;
  final String description;
  final List<String> supportedPlatforms;

  // Get default ports for each protocol
  List<int> get defaultPorts {
    switch (this) {
      case VpnProtocol.openVpn:
        return [443, 1194, 1834]; // TCP:443 prioritized
      case VpnProtocol.sslVpn:
        return [443]; // TCP:443, UDP supported
      case VpnProtocol.l2tpIpsec:
        return [1701, 500, 4500];
      case VpnProtocol.msSstp:
        return [443]; // SSTP over 443
    }
  }

  // Get protocol identifier for server communication
  String get protocolId {
    switch (this) {
      case VpnProtocol.openVpn:
        return 'openvpn';
      case VpnProtocol.sslVpn:
        return 'sslvpn';
      case VpnProtocol.l2tpIpsec:
        return 'l2tp';
      case VpnProtocol.msSstp:
        return 'sstp';
    }
  }

  // Check if protocol requires client software
  bool get requiresClient {
    switch (this) {
      case VpnProtocol.openVpn:
        return true;
      case VpnProtocol.sslVpn:
        return false; // Browser-based
      case VpnProtocol.l2tpIpsec:
        return false; // Built into OS
      case VpnProtocol.msSstp:
        return false; // Built into Windows
    }
  }

  // Get connection method description
  String get connectionMethod {
    switch (this) {
      case VpnProtocol.openVpn:
        return 'Config file • TCP:443';
      case VpnProtocol.sslVpn:
        return 'TCP:443 • UDP Supported';
      case VpnProtocol.l2tpIpsec:
        return 'Connect guide • Built-in support';
      case VpnProtocol.msSstp:
        return 'SSTP Hostname: public-vpn-120.opengw.net';
    }
  }
}