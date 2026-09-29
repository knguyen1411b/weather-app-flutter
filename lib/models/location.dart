class Location {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? countryCode;
  final String? admin1;
  final String? timezone;

  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.countryCode,
    this.admin1,
    this.timezone,
  });

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      return '$name, $admin1';
    }
    if (country != null && country!.isNotEmpty) {
      return '$name, $country';
    }
    return name;
  }

  String get fullLocationText {
    final parts = <String>[name];
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      parts.add(admin1!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    return parts.join(', ');
  }

  String get flagEmoji {
    if (countryCode == null || countryCode!.length != 2) return '📍';
    final code = countryCode!.toUpperCase();
    final firstChar = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final secondChar = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String? ?? 'Chưa xác định',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'country_code': countryCode,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude.toStringAsFixed(3) == other.latitude.toStringAsFixed(3) &&
          longitude.toStringAsFixed(3) == other.longitude.toStringAsFixed(3);

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}
