import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/vpn_server.dart';

class VpnGateService {
  static const String apiUrl = 'https://www.vpngate.net/api/iphone/';
  static const String username = 'vpn';
  static const String password = 'vpn';

  static Future<List<VpnServer>> fetchVpnServers() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'GurkhaVPN/1.0',
          'Accept': 'text/csv',
        },
      );

      if (response.statusCode == 200) {
        return _parseCsvData(response.body);
      } else {
        throw Exception('Failed to fetch VPN servers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching VPN servers: $e');
    }
  }

  static List<VpnServer> _parseCsvData(String csvData) {
    try {
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);
      final List<VpnServer> servers = [];

      for (int i = 1; i < csvTable.length; i++) {
        try {
          final row = csvTable[i].map((e) => e?.toString() ?? '').toList();
          if (row.length >= 15 && row[1].isNotEmpty) {
            final server = VpnServer.fromCsvRow(row);
            // Filter for reliable servers only
            if (server.isOnline && 
                server.openVpnConfigDataBase64.isNotEmpty &&
                server.ping > 0 && server.ping < 300 &&  // Good ping
                server.score > 1000000 &&                // High score
                server.uptime > 86400) {                 // At least 1 day uptime
              servers.add(server);
            }
          }
        } catch (e) {
          continue;
        }
      }

      // Sort by reliability score (combination of ping, score, and uptime)
      servers.sort((a, b) {
        double aReliability = (a.score / 1000000) * (1000 / (a.ping + 1)) * (a.uptime / 86400);
        double bReliability = (b.score / 1000000) * (1000 / (b.ping + 1)) * (b.uptime / 86400);
        return bReliability.compareTo(aReliability);
      });
      
      return servers; // Return all reliable servers
    } catch (e) {
      throw Exception('Error parsing CSV data: $e');
    }
  }

  static Future<List<VpnServer>> getServersByCountry(String countryCode) async {
    final allServers = await fetchVpnServers();
    return allServers
        .where((server) => 
            server.countryShort.toLowerCase() == countryCode.toLowerCase())
        .toList();
  }

  static Future<List<String>> getAvailableCountries() async {
    final allServers = await fetchVpnServers();
    final countries = <String>{};
    
    for (final server in allServers) {
      if (server.countryShort.isNotEmpty && server.countryLong.isNotEmpty) {
        countries.add(server.countryShort);
      }
    }
    
    return countries.toList()..sort();
  }

  static Future<VpnServer?> getBestServerForCountry(String countryCode) async {
    final servers = await getServersByCountry(countryCode);
    if (servers.isEmpty) return null;
    
    servers.sort((a, b) {
      final aScore = a.score + (a.ping < 100 ? 100 : 0);
      final bScore = b.score + (b.ping < 100 ? 100 : 0);
      return bScore.compareTo(aScore);
    });
    
    return servers.first;
  }

  static String decodeOpenVpnConfig(String base64Config) {
    try {
      final bytes = base64.decode(base64Config);
      return utf8.decode(bytes);
    } catch (e) {
      return '';
    }
  }

  static Map<String, String> getVpnCredentials() {
    return {
      'username': username,
      'password': password,
    };
  }

  static Future<Map<String, dynamic>> getServersAsJson() async {
    final servers = await fetchVpnServers();
    return {
      'servers': servers.map((server) => server.toJson()).toList(),
      'total_count': servers.length,
      'countries': await getAvailableCountries(),
      'credentials': getVpnCredentials(),
      'last_updated': DateTime.now().toIso8601String(),
    };
  }
}