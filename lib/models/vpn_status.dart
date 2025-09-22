enum VpnConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnStatus {
  final VpnConnectionStatus status;
  final String? selectedCountryCode;
  final String? selectedCountryName;
  final double downloadSpeed;
  final double uploadSpeed;
  final String? ipAddress;
  final String? location;

  const VpnStatus({
    required this.status,
    this.selectedCountryCode,
    this.selectedCountryName,
    this.downloadSpeed = 0.0,
    this.uploadSpeed = 0.0,
    this.ipAddress,
    this.location,
  });

  VpnStatus copyWith({
    VpnConnectionStatus? status,
    String? selectedCountryCode,
    String? selectedCountryName,
    double? downloadSpeed,
    double? uploadSpeed,
    String? ipAddress,
    String? location,
  }) {
    return VpnStatus(
      status: status ?? this.status,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      selectedCountryName: selectedCountryName ?? this.selectedCountryName,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
    );
  }
}