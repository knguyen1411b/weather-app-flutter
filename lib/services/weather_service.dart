import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/air_quality.dart';
import '../models/weather.dart';

class WeatherService {
  Future<FullWeatherData> getFullWeather(double latitude, double longitude) async {
    final weatherUrl = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weather_code,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m,uv_index,visibility'
      '&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,precipitation,weather_code,wind_speed_10m,uv_index,is_day'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_sum,precipitation_probability_max,wind_speed_10m_max'
      '&timezone=auto'
      '&forecast_days=8',
    );

    final aqiUrl = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=european_aqi,us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone'
      '&timezone=auto',
    );

    try {
      // Execute both requests concurrently for maximum speed
      final results = await Future.wait([
        http.get(weatherUrl).timeout(const Duration(seconds: 12)),
        http.get(aqiUrl).timeout(const Duration(seconds: 12)).catchError((_) => http.Response('{}', 500)),
      ]);

      final weatherResponse = results[0];
      final aqiResponse = results[1];

      if (weatherResponse.statusCode != 200) {
        throw Exception('Không thể tải dữ liệu thời tiết (Mã lỗi: ${weatherResponse.statusCode})');
      }

      final weatherJson = jsonDecode(weatherResponse.body);
      final currentWeather = Weather.fromJson(weatherJson);

      // Parse Hourly forecast
      final List<HourlyForecast> hourlyList = [];
      if (weatherJson['hourly'] != null) {
        final hourly = weatherJson['hourly'];
        final times = (hourly['time'] as List?) ?? [];
        final temps = (hourly['temperature_2m'] as List?) ?? [];
        final appTemps = (hourly['apparent_temperature'] as List?) ?? [];
        final codes = (hourly['weather_code'] as List?) ?? [];
        final pops = (hourly['precipitation_probability'] as List?) ?? [];
        final precips = (hourly['precipitation'] as List?) ?? [];
        final winds = (hourly['wind_speed_10m'] as List?) ?? [];
        final uvs = (hourly['uv_index'] as List?) ?? [];
        final isDays = (hourly['is_day'] as List?) ?? [];

        final now = DateTime.now();
        // Find current hour index or start from now
        int startIndex = 0;
        for (int i = 0; i < times.length; i++) {
          final dt = DateTime.tryParse(times[i].toString());
          if (dt != null && dt.isAfter(now.subtract(const Duration(minutes: 50)))) {
            startIndex = i;
            break;
          }
        }

        // Take next 24 hours
        final count = (startIndex + 24 <= times.length) ? 24 : (times.length - startIndex);
        for (int i = startIndex; i < startIndex + count; i++) {
          hourlyList.add(HourlyForecast.fromLists(
            timeStr: times[i].toString(),
            temp: temps.length > i ? (temps[i] ?? 0) : 0,
            appTemp: appTemps.length > i ? (appTemps[i] ?? 0) : 0,
            code: codes.length > i ? (codes[i] ?? 0) : 0,
            pop: pops.length > i ? (pops[i] ?? 0) : 0,
            precip: precips.length > i ? (precips[i] ?? 0) : 0,
            wind: winds.length > i ? (winds[i] ?? 0) : 0,
            uv: uvs.length > i ? (uvs[i] ?? 0) : 0,
            day: isDays.length > i ? (isDays[i] ?? 1) : 1,
          ));
        }
      }

      // Parse Daily forecast (7 days)
      final List<DailyForecast> dailyList = [];
      if (weatherJson['daily'] != null) {
        final daily = weatherJson['daily'];
        final dates = (daily['time'] as List?) ?? [];
        final codes = (daily['weather_code'] as List?) ?? [];
        final maxTemps = (daily['temperature_2m_max'] as List?) ?? [];
        final minTemps = (daily['temperature_2m_min'] as List?) ?? [];
        final appMaxTemps = (daily['apparent_temperature_max'] as List?) ?? [];
        final appMinTemps = (daily['apparent_temperature_min'] as List?) ?? [];
        final sunrises = (daily['sunrise'] as List?) ?? [];
        final sunsets = (daily['sunset'] as List?) ?? [];
        final maxUvs = (daily['uv_index_max'] as List?) ?? [];
        final precips = (daily['precipitation_sum'] as List?) ?? [];
        final maxPops = (daily['precipitation_probability_max'] as List?) ?? [];
        final maxWinds = (daily['wind_speed_10m_max'] as List?) ?? [];

        for (int i = 0; i < dates.length && i < 7; i++) {
          dailyList.add(DailyForecast(
            date: DateTime.tryParse(dates[i].toString()) ?? DateTime.now().add(Duration(days: i)),
            weatherCode: codes.length > i ? (codes[i] as num).toInt() : 0,
            tempMax: maxTemps.length > i ? (maxTemps[i] as num).toDouble() : 0.0,
            tempMin: minTemps.length > i ? (minTemps[i] as num).toDouble() : 0.0,
            apparentTempMax: appMaxTemps.length > i ? (appMaxTemps[i] as num).toDouble() : 0.0,
            apparentTempMin: appMinTemps.length > i ? (appMinTemps[i] as num).toDouble() : 0.0,
            sunrise: sunrises.length > i && sunrises[i] != null ? DateTime.tryParse(sunrises[i].toString()) : null,
            sunset: sunsets.length > i && sunsets[i] != null ? DateTime.tryParse(sunsets[i].toString()) : null,
            uvIndexMax: maxUvs.length > i ? (maxUvs[i] as num).toDouble() : 0.0,
            precipitationSum: precips.length > i ? (precips[i] as num).toDouble() : 0.0,
            precipitationProbabilityMax: maxPops.length > i ? (maxPops[i] as num).toInt() : 0,
            windSpeedMax: maxWinds.length > i ? (maxWinds[i] as num).toDouble() : 0.0,
          ));
        }
      }

      // Parse Air Quality
      AirQuality airQuality = AirQuality();
      if (aqiResponse.statusCode == 200) {
        final aqiJson = jsonDecode(aqiResponse.body);
        airQuality = AirQuality.fromJson(aqiJson);
      }

      return FullWeatherData(
        current: currentWeather,
        hourly: hourlyList,
        daily: dailyList,
        airQuality: airQuality,
      );
    } catch (e) {
      throw Exception('Không thể tải dữ liệu thời tiết: $e');
    }
  }

  // Backwards compatibility method
  Future<Weather> getWeather(double latitude, double longitude) async {
    final full = await getFullWeather(latitude, longitude);
    return full.current;
  }
}
