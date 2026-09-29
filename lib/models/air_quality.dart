import 'package:flutter/material.dart';

class AirQuality {
  final int? europeanAqi;
  final int? usAqi;
  final double? pm25;
  final double? pm10;
  final double? carbonMonoxide;
  final double? nitrogenDioxide;
  final double? sulphurDioxide;
  final double? ozone;

  AirQuality({
    this.europeanAqi,
    this.usAqi,
    this.pm25,
    this.pm10,
    this.carbonMonoxide,
    this.nitrogenDioxide,
    this.sulphurDioxide,
    this.ozone,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current == null) return AirQuality();

    return AirQuality(
      europeanAqi: (current['european_aqi'] as num?)?.toInt(),
      usAqi: (current['us_aqi'] as num?)?.toInt(),
      pm25: (current['pm2_5'] as num?)?.toDouble(),
      pm10: (current['pm10'] as num?)?.toDouble(),
      carbonMonoxide: (current['carbon_monoxide'] as num?)?.toDouble(),
      nitrogenDioxide: (current['nitrogen_dioxide'] as num?)?.toDouble(),
      sulphurDioxide: (current['sulphur_dioxide'] as num?)?.toDouble(),
      ozone: (current['ozone'] as num?)?.toDouble(),
    );
  }

  int get aqiValue => usAqi ?? europeanAqi ?? 30;

  String get aqiLevel {
    final val = aqiValue;
    if (val <= 50) return 'Tốt';
    if (val <= 100) return 'Trung bình';
    if (val <= 150) return 'Kém (Nhạy cảm)';
    if (val <= 200) return 'Xấu';
    if (val <= 300) return 'Rất xấu';
    return 'Nguy hại';
  }

  Color get aqiColor {
    final val = aqiValue;
    if (val <= 50) return const Color(0xFF00E676); // Green
    if (val <= 100) return const Color(0xFFFFD600); // Yellow
    if (val <= 150) return const Color(0xFFFF9100); // Orange
    if (val <= 200) return const Color(0xFFFF3D00); // Red
    if (val <= 300) return const Color(0xFF9C27B0); // Purple
    return const Color(0xFF880E4F); // Maroon
  }

  String get aqiAdvice {
    final val = aqiValue;
    if (val <= 50) {
      return 'Chất lượng không khí tuyệt vời. Hoàn hảo cho các hoạt động ngoài trời.';
    }
    if (val <= 100) {
      return 'Chất lượng không khí chấp nhận được. Người nhạy cảm nên chú ý.';
    }
    if (val <= 150) {
      return 'Nhóm người nhạy cảm nên hạn chế hoạt động mạnh ngoài trời kéo dài.';
    }
    if (val <= 200) {
      return 'Mọi người nên đeo khẩu trang lọc bụi và hạn chế ra đường.';
    }
    return 'Khuyến cáo ở trong nhà, đóng cửa sổ và sử dụng máy lọc không khí.';
  }
}
