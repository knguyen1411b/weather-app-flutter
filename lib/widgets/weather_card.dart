import 'package:flutter/material.dart';
import '../models/location.dart';
import '../models/weather.dart';
import 'air_quality_widget.dart';
import 'daily_forecast_widget.dart';
import 'hourly_forecast_widget.dart';
import 'sun_moon_widget.dart';
import 'weather_header.dart';
import 'weather_metrics_grid.dart';

class WeatherCard extends StatelessWidget {
  final Location location;
  final FullWeatherData weatherData;
  final bool isCelsius;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const WeatherCard({
    super.key,
    required this.location,
    required this.weatherData,
    this.isCelsius = true,
    this.onSearchTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final todayDaily = weatherData.daily.isNotEmpty ? weatherData.daily.first : null;

    return Column(
      children: [
        // 1. Weather Header (Location, Date, Big Temp, Advice)
        WeatherHeader(
          location: location,
          weatherData: weatherData,
          isCelsius: isCelsius,
          onSearchTap: onSearchTap,
          onFavoriteTap: onFavoriteTap,
          isFavorite: isFavorite,
        ),

        const SizedBox(height: 24),

        // 2. Hourly Forecast (24 Hours)
        HourlyForecastWidget(
          hourlyList: weatherData.hourly,
          isCelsius: isCelsius,
        ),

        const SizedBox(height: 18),

        // 3. 7-Day Forecast
        DailyForecastWidget(
          dailyList: weatherData.daily,
          isCelsius: isCelsius,
        ),

        const SizedBox(height: 18),

        // 4. Air Quality Card
        AirQualityWidget(
          airQuality: weatherData.airQuality,
        ),

        const SizedBox(height: 18),

        // 5. Sunrise & Sunset
        if (todayDaily != null)
          SunMoonWidget(
            sunrise: todayDaily.sunrise,
            sunset: todayDaily.sunset,
          ),

        const SizedBox(height: 18),

        // 6. Detailed Metrics Grid (UV, Wind, Humidity, Pressure, Visibility, Clouds)
        WeatherMetricsGrid(
          weather: weatherData.current,
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
