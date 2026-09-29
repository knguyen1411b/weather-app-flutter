import 'dart:math';
import 'package:flutter/material.dart';
import '../models/weather.dart';
import 'glass_card.dart';

class WeatherMetricsGrid extends StatelessWidget {
  final Weather weather;

  const WeatherMetricsGrid({super.key, required this.weather});

  // Calculate approximate dew point (Magnus formula)
  double _calculateDewPoint(double temp, double humidity) {
    const a = 17.27;
    const b = 237.7;
    final alpha = ((a * temp) / (b + temp)) + log(humidity / 100.0);
    return (b * alpha) / (a - alpha);
  }

  @override
  Widget build(BuildContext context) {
    final dewPoint = _calculateDewPoint(weather.temperature2m, weather.relativeHumidity2m);

    return Column(
      children: [
        // Row 1: UV Index & Wind
        Row(
          children: [
            // UV Index Card
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          'CHỈ SỐ UV',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      weather.uvIndex.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weather.uvIndexDescription,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: weather.uvColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.uvIndex > 5
                          ? 'Cần bảo vệ mắt và da khi ra ngoài'
                          : 'Mức độ an toàn cho da',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Wind & Direction Card
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.air_rounded, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          'GIÓ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather.windSpeed10m.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'km/h',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),

                        // Mini Animated Compass Widget
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1.5),
                          ),
                          child: Center(
                            child: Transform.rotate(
                              angle: (weather.windDirection10m * pi) / 180,
                              child: const Icon(
                                Icons.navigation_rounded,
                                size: 22,
                                color: Color(0xFF64B5F6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hướng ${weather.windDirectionText}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (weather.windGusts10m > 0)
                      Text(
                        'Gió giật: ${weather.windGusts10m.toStringAsFixed(0)} km/h',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Row 2: Humidity & Pressure
        Row(
          children: [
            // Humidity Card
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop_rounded, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          'ĐỘ ẨM',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${weather.relativeHumidity2m.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Điểm sương hiện tại là ${dewPoint.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Pressure Card
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed_rounded, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          'ÁP SUẤT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      weather.pressureMsl.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'hPa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.pressureMsl >= 1013 ? 'Áp suất cao, ổn định' : 'Áp suất thấp',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Row 3: Visibility & Precipitation
        Row(
          children: [
            // Visibility Card
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.visibility_rounded, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          'TẦM NHÌN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      weather.visibility.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'km',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.visibility >= 10 ? 'Tầm nhìn rất rõ ràng' : 'Tầm nhìn bị hạn chế',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Cloud Cover & Precipitation
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_outlined, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          'MÂY & MƯA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${weather.cloudCover}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Độ che phủ mây',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lượng mưa: ${weather.precipitation.toStringAsFixed(1)} mm',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
