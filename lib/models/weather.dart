import 'package:flutter/material.dart';
import 'air_quality.dart';

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final int precipitationProbability;
  final double precipitation;
  final double windSpeed;
  final double uvIndex;
  final bool isDay;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.precipitation,
    required this.windSpeed,
    required this.uvIndex,
    required this.isDay,
  });

  factory HourlyForecast.fromLists({
    required String timeStr,
    required num temp,
    required num appTemp,
    required num code,
    required num pop,
    required num precip,
    required num wind,
    required num uv,
    required num day,
  }) {
    return HourlyForecast(
      time: DateTime.parse(timeStr),
      temperature: temp.toDouble(),
      apparentTemperature: appTemp.toDouble(),
      weatherCode: code.toInt(),
      precipitationProbability: pop.toInt(),
      precipitation: precip.toDouble(),
      windSpeed: wind.toDouble(),
      uvIndex: uv.toDouble(),
      isDay: day.toInt() == 1,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final double apparentTempMax;
  final double apparentTempMin;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double uvIndexMax;
  final double precipitationSum;
  final int precipitationProbabilityMax;
  final double windSpeedMax;

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.apparentTempMax,
    required this.apparentTempMin,
    this.sunrise,
    this.sunset,
    required this.uvIndexMax,
    required this.precipitationSum,
    required this.precipitationProbabilityMax,
    required this.windSpeedMax,
  });
}

class Weather {
  final double temperature2m; // °C
  final double relativeHumidity2m; // %
  final double apparentTemperature; // °C
  final int weatherCode;
  final int isDay; // 1 = ngày, 0 = đêm
  final int cloudCover; // %
  final double pressureMsl; // hPa
  final double surfacePressure; // hPa
  final double windSpeed10m; // km/h
  final int windDirection10m; // °
  final double windGusts10m; // km/h
  final double precipitation; // mm
  final double rain; // mm
  final double showers; // mm
  final double snowfall; // cm
  final double uvIndex;
  final double visibility; // km
  final DateTime time;

  Weather({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.isDay,
    required this.cloudCover,
    required this.pressureMsl,
    required this.surfacePressure,
    required this.windSpeed10m,
    required this.windDirection10m,
    required this.windGusts10m,
    required this.precipitation,
    required this.rain,
    required this.showers,
    required this.snowfall,
    required this.uvIndex,
    required this.visibility,
    required this.time,
  });

  bool get isDayTime => isDay == 1;

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};

    return Weather(
      temperature2m: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m:
          (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature:
          (current['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      isDay: (current['is_day'] as num?)?.toInt() ?? 1,
      cloudCover: (current['cloud_cover'] as num?)?.toInt() ?? 0,
      pressureMsl: (current['pressure_msl'] as num?)?.toDouble() ?? 1013.25,
      surfacePressure:
          (current['surface_pressure'] as num?)?.toDouble() ?? 1013.25,
      windSpeed10m: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      windDirection10m: (current['wind_direction_10m'] as num?)?.toInt() ?? 0,
      windGusts10m: (current['wind_gusts_10m'] as num?)?.toDouble() ?? 0.0,
      precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      rain: (current['rain'] as num?)?.toDouble() ?? 0.0,
      showers: (current['showers'] as num?)?.toDouble() ?? 0.0,
      snowfall: (current['snowfall'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (current['uv_index'] as num?)?.toDouble() ?? 0.0,
      visibility: ((current['visibility'] as num?)?.toDouble() ?? 10000.0) /
          1000.0, // convert m to km
      time: current['time'] != null
          ? DateTime.tryParse(current['time']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Compass direction name in Vietnamese
  String get windDirectionText {
    final deg = windDirection10m % 360;
    if (deg >= 337.5 || deg < 22.5) return 'Bắc (N)';
    if (deg < 67.5) return 'Đông Bắc (NE)';
    if (deg < 112.5) return 'Đông (E)';
    if (deg < 157.5) return 'Đông Nam (SE)';
    if (deg < 202.5) return 'Nam (S)';
    if (deg < 247.5) return 'Tây Nam (SW)';
    if (deg < 292.5) return 'Tây (W)';
    return 'Tây Bắc (NW)';
  }

  // UV Index description
  String get uvIndexDescription {
    if (uvIndex <= 2) return 'Thấp';
    if (uvIndex <= 5) return 'Trung bình';
    if (uvIndex <= 7) return 'Cao';
    if (uvIndex <= 10) return 'Rất cao';
    return 'Nguy hại';
  }

  Color get uvColor {
    if (uvIndex <= 2) return const Color(0xFF00E676);
    if (uvIndex <= 5) return const Color(0xFFFFD600);
    if (uvIndex <= 7) return const Color(0xFFFF9100);
    if (uvIndex <= 10) return const Color(0xFFFF3D00);
    return const Color(0xFF9C27B0);
  }
}

class FullWeatherData {
  final Weather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final AirQuality airQuality;

  FullWeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.airQuality,
  });

  // Helper for weather condition text
  static String getWeatherDescription(int code, {bool isDay = true}) {
    switch (code) {
      case 0:
        return isDay ? 'Trời nắng quang' : 'Đêm quang đãng';
      case 1:
        return isDay ? 'Ít mây, nắng nhẹ' : 'Ít mây';
      case 2:
        return 'Mây rải rác';
      case 3:
        return 'Nhiều mây, u ám';
      case 45:
        return 'Sương mù';
      case 48:
        return 'Sương mù đọng băng';
      case 51:
        return 'Mưa phùn nhẹ';
      case 53:
        return 'Mưa phùn vừa';
      case 55:
        return 'Mưa phùn dày đặc';
      case 56:
      case 57:
        return 'Mưa phùn buốt giá';
      case 61:
        return 'Mưa nhẹ';
      case 63:
        return 'Mưa vừa';
      case 65:
        return 'Mưa to';
      case 66:
      case 67:
        return 'Mưa băng giá';
      case 71:
        return 'Tuyết rơi nhẹ';
      case 73:
        return 'Tuyết rơi vừa';
      case 75:
        return 'Tuyết rơi dày đặc';
      case 77:
        return 'Hạt tuyết';
      case 80:
        return 'Mưa rào nhẹ';
      case 81:
        return 'Mưa rào vừa';
      case 82:
        return 'Mưa rào rất to';
      case 85:
      case 86:
        return 'Mưa rào tuyết';
      case 95:
        return 'Dông bão';
      case 96:
      case 99:
        return 'Dông có mưa đá';
      default:
        return 'Nhiều mây';
    }
  }

  // Weather icon
  static IconData getWeatherIcon(int code, {bool isDay = true}) {
    switch (code) {
      case 0:
        return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
      case 1:
        return isDay ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded;
      case 2:
        return Icons.cloud_queue_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.blur_on_rounded;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain_rounded;
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return Icons.water_drop_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit_rounded;
      case 80:
      case 81:
      case 82:
      case 85:
      case 86:
        return Icons.shower_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.cloud_rounded;
    }
  }

  // Weather gradient colors based on condition & day/night
  static List<Color> getWeatherGradients(int code, {bool isDay = true}) {
    if (!isDay) {
      if (code >= 95) {
        // Night Thunderstorm
        return const [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)];
      } else if (code >= 51) {
        // Night Rain
        return const [Color(0xFF141E30), Color(0xFF243B55), Color(0xFF1B2A4A)];
      } else if (code >= 71) {
        // Night Snow
        return const [Color(0xFF1C2833), Color(0xFF2E4053), Color(0xFF34495E)];
      } else {
        // Clear / Cloudy Night
        return const [Color(0xFF0A1128), Color(0xFF1C2541), Color(0xFF0B132B)];
      }
    }

    // Day time gradients
    if (code == 0) {
      // Clear sunny
      return const [Color(0xFF2193B0), Color(0xFF6DD5ED), Color(0xFF3A7BD5)];
    } else if (code == 1 || code == 2) {
      // Partly cloudy
      return const [Color(0xFF2980B9), Color(0xFF6DD5FA), Color(0xFF4CA1AF)];
    } else if (code == 3) {
      // Overcast
      return const [Color(0xFF3E5151), Color(0xFFDECBA4), Color(0xFF606C88)];
    } else if (code == 45 || code == 48) {
      // Fog
      return const [Color(0xFF536976), Color(0xFF292E49), Color(0xFF3F4C6B)];
    } else if (code >= 51 && code <= 67) {
      // Rain
      return const [Color(0xFF2C3E50), Color(0xFF3498DB), Color(0xFF2980B9)];
    } else if (code >= 71 && code <= 77) {
      // Snow
      return const [Color(0xFF83A4D4), Color(0xFFB6FBFF), Color(0xFF70A1FF)];
    } else if (code >= 80 && code <= 86) {
      // Shower
      return const [Color(0xFF1F4037), Color(0xFF99F2C8), Color(0xFF2C3E50)];
    } else if (code >= 95) {
      // Thunderstorm
      return const [Color(0xFF16222F), Color(0xFF3B4371), Color(0xFF1F1C2C)];
    }

    return const [Color(0xFF2193B0), Color(0xFF6DD5ED), Color(0xFF3A7BD5)];
  }

  // Dynamic smart weather summary advice
  String get dynamicAdvice {
    final code = current.weatherCode;
    final temp = current.temperature2m;
    final rain = current.precipitation;
    final uv = current.uvIndex;
    final aqi = airQuality.aqiValue;

    if (code >= 95) {
      return '⚠️ Cảnh báo dông bão! Hãy ở trong nhà và hạn chế di chuyển ngoài trời.';
    }
    if (rain > 1.0 || (code >= 51 && code <= 82)) {
      return '🌧️ Đang có mưa hoặc mưa rào. Đừng quên mang theo ô hoặc áo mưa khi ra ngoài.';
    }
    if (uv >= 8) {
      return '☀️ Chỉ số UV cực cao ($uv). Nhớ thoa kem chống nắng, đeo kính râm và mũ nón.';
    }
    if (aqi > 150) {
      return '😷 Chất lượng không khí kém (AQI $aqi). Nên đeo khẩu trang chống bụi mịn PM2.5.';
    }
    if (temp >= 35) {
      return '🔥 Trời rất nắng nóng (${temp.toStringAsFixed(1)}°C). Bổ sung nhiều nước và tránh nắng gắt.';
    }
    if (temp <= 15) {
      return '🧥 Tiết trời khá lạnh (${temp.toStringAsFixed(1)}°C). Nhớ mặc thêm áo ấm khi ra ngoài.';
    }
    return '✨ Thời tiết rất dễ chịu và lý tưởng cho các hoạt động ngoài trời.';
  }
}
