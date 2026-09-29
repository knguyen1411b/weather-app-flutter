import 'package:flutter/material.dart';
import '../models/location.dart';
import '../models/weather.dart';
import 'glass_card.dart';

class WeatherHeader extends StatelessWidget {
  final Location location;
  final FullWeatherData weatherData;
  final bool isCelsius;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const WeatherHeader({
    super.key,
    required this.location,
    required this.weatherData,
    required this.isCelsius,
    this.onSearchTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  String _formatTemp(double celsius) {
    if (isCelsius) {
      return '${celsius.round()}°';
    } else {
      final fahrenheit = (celsius * 9 / 5) + 32;
      return '${fahrenheit.round()}°';
    }
  }

  String _formatVietnameseDate(DateTime dt) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final dayName = weekdays[dt.weekday - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$dayName, $day/$month';
  }

  @override
  Widget build(BuildContext context) {
    final weather = weatherData.current;
    final todayDaily = weatherData.daily.isNotEmpty ? weatherData.daily.first : null;
    final now = DateTime.now();
    final formattedDate = _formatVietnameseDate(now);

    return Column(
      children: [
        // Location Title & Flag
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              location.flagEmoji,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                location.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        if (location.admin1 != null && location.admin1 != location.name) ...[
          const SizedBox(height: 2),
          Text(
            location.country != null
                ? '${location.admin1}, ${location.country}'
                : location.admin1!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],

        const SizedBox(height: 4),

        // Date & Time
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            formattedDate,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Hero Weather Icon & Big Temp Display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing animated-style Weather Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                FullWeatherData.getWeatherIcon(
                  weather.weatherCode,
                  isDay: weather.isDayTime,
                ),
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            // Temperature number
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTemp(weather.temperature2m),
                  style: const TextStyle(
                    fontSize: 76,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Cảm giác như ${_formatTemp(weather.apparentTemperature)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Weather Condition Description
        Text(
          FullWeatherData.getWeatherDescription(
            weather.weatherCode,
            isDay: weather.isDayTime,
          ),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),

        // Today Min / Max
        if (todayDaily != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_upward_rounded, size: 16, color: Color(0xFFFF8A80)),
              Text(
                ' Cao: ${_formatTemp(todayDaily.tempMax)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_downward_rounded, size: 16, color: Color(0xFF80D8FF)),
              Text(
                ' Thấp: ${_formatTemp(todayDaily.tempMin)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 18),

        // Dynamic Smart Advice Card
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 18,
          opacity: 0.12,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFFFD54F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  weatherData.dynamicAdvice,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
