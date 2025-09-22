class VpnServer {
  final String hostName;
  final String ip;
  final int score;
  final int ping;
  final int speed;
  final String countryLong;
  final String countryShort;
  final int numVpnSessions;
  final int uptime;
  final int totalUsers;
  final int totalTraffic;
  final String logType;
  final String operator;
  final String message;
  final String openVpnConfigDataBase64;
  final List<String> supportedProtocols;

  const VpnServer({
    required this.hostName,
    required this.ip,
    required this.score,
    required this.ping,
    required this.speed,
    required this.countryLong,
    required this.countryShort,
    required this.numVpnSessions,
    required this.uptime,
    required this.totalUsers,
    required this.totalTraffic,
    required this.logType,
    required this.operator,
    required this.message,
    required this.openVpnConfigDataBase64,
    this.supportedProtocols = const ['openvpn', 'sslvpn', 'l2tp', 'sstp'],
  });

  factory VpnServer.fromCsvRow(List<String> row) {
    return VpnServer(
      hostName: row.isNotEmpty ? row[0] : '',
      ip: row.length > 1 ? row[1] : '',
      score: row.length > 2 ? int.tryParse(row[2]) ?? 0 : 0,
      ping: row.length > 3 ? int.tryParse(row[3]) ?? 0 : 0,
      speed: row.length > 4 ? int.tryParse(row[4]) ?? 0 : 0,
      countryLong: row.length > 5 ? row[5] : '',
      countryShort: row.length > 6 ? row[6] : '',
      numVpnSessions: row.length > 7 ? int.tryParse(row[7]) ?? 0 : 0,
      uptime: row.length > 8 ? int.tryParse(row[8]) ?? 0 : 0,
      totalUsers: row.length > 9 ? int.tryParse(row[9]) ?? 0 : 0,
      totalTraffic: row.length > 10 ? int.tryParse(row[10]) ?? 0 : 0,
      logType: row.length > 11 ? row[11] : '',
      operator: row.length > 12 ? row[12] : '',
      message: row.length > 13 ? row[13] : '',
      openVpnConfigDataBase64: row.length > 14 ? row[14] : '',
      supportedProtocols: const ['openvpn', 'sslvpn', 'l2tp', 'sstp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostName': hostName,
      'ip': ip,
      'score': score,
      'ping': ping,
      'speed': speed,
      'countryLong': countryLong,
      'countryShort': countryShort,
      'numVpnSessions': numVpnSessions,
      'uptime': uptime,
      'totalUsers': totalUsers,
      'totalTraffic': totalTraffic,
      'logType': logType,
      'operator': operator,
      'message': message,
      'openVpnConfigDataBase64': openVpnConfigDataBase64,
      'supportedProtocols': supportedProtocols,
    };
  }

  String get flagEmoji {
    switch (countryShort.toUpperCase()) {
      case 'JP':
        return '🇯🇵';
      case 'KR':
        return '🇰🇷';
      case 'US':
        return '🇺🇸';
      case 'CA':
        return '🇨🇦';
      case 'GB':
        return '🇬🇧';
      case 'DE':
        return '🇩🇪';
      case 'FR':
        return '🇫🇷';
      case 'IT':
        return '🇮🇹';
      case 'ES':
        return '🇪🇸';
      case 'NL':
        return '🇳🇱';
      case 'AU':
        return '🇦🇺';
      case 'BR':
        return '🇧🇷';
      case 'IN':
        return '🇮🇳';
      case 'SG':
        return '🇸🇬';
      case 'TH':
        return '🇹🇭';
      case 'VN':
        return '🇻🇳';
      case 'MY':
        return '🇲🇾';
      case 'ID':
        return '🇮🇩';
      case 'PH':
        return '🇵🇭';
      case 'HK':
        return '🇭🇰';
      case 'TW':
        return '🇹🇼';
      case 'CN':
        return '🇨🇳';
      case 'RU':
        return '🇷🇺';
      case 'UA':
        return '🇺🇦';
      case 'TR':
        return '🇹🇷';
      case 'IL':
        return '🇮🇱';
      case 'AE':
        return '🇦🇪';
      case 'SA':
        return '🇸🇦';
      case 'EG':
        return '🇪🇬';
      case 'ZA':
        return '🇿🇦';
      case 'MX':
        return '🇲🇽';
      case 'AR':
        return '🇦🇷';
      case 'CL':
        return '🇨🇱';
      case 'CO':
        return '🇨🇴';
      case 'PE':
        return '🇵🇪';
      case 'VE':
        return '🇻🇪';
      case 'EC':
        return '🇪🇨';
      case 'UY':
        return '🇺🇾';
      case 'PY':
        return '🇵🇾';
      case 'BO':
        return '🇧🇴';
      case 'CR':
        return '🇨🇷';
      case 'PA':
        return '🇵🇦';
      case 'GT':
        return '🇬🇹';
      case 'HN':
        return '🇭🇳';
      case 'SV':
        return '🇸🇻';
      case 'NI':
        return '🇳🇮';
      case 'CU':
        return '🇨🇺';
      case 'DO':
        return '🇩🇴';
      case 'JM':
        return '🇯🇲';
      case 'TT':
        return '🇹🇹';
      case 'BB':
        return '🇧🇧';
      case 'GD':
        return '🇬🇩';
      case 'LC':
        return '🇱🇨';
      case 'VC':
        return '🇻🇨';
      case 'AG':
        return '🇦🇬';
      case 'DM':
        return '🇩🇲';
      case 'KN':
        return '🇰🇳';
      case 'MS':
        return '🇲🇸';
      case 'AI':
        return '🇦🇮';
      case 'VG':
        return '🇻🇬';
      case 'BM':
        return '🇧🇲';
      default:
        return '🌍';
    }
  }

  double get speedInMbps {
    return speed / 1000000.0; // Convert from bits to Mbps
  }

  bool get isOnline {
    return ping > 0 && ping < 1000; // Consider server online if ping is reasonable
  }
}