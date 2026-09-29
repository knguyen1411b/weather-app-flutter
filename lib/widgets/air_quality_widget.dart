import 'package:flutter/material.dart';
import '../models/air_quality.dart';
import 'glass_card.dart';

class AirQualityWidget extends StatelessWidget {
  final AirQuality airQuality;

  const AirQualityWidget({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final aqi = airQuality.aqiValue;
    final aqiColor = airQuality.aqiColor;
    final aqiLevel = airQuality.aqiLevel;
    final aqiAdvice = airQuality.aqiAdvice;

    // Progress bar from 0 to 300
    final progress = (aqi / 300.0).clamp(0.0, 1.0);

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.air_rounded,
                size: 18,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                'CHẤT LƯỢNG KHÔNG KHÍ (AQI)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Main AQI Value & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$aqi',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AQI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: aqiColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: aqiColor.withValues(alpha: 0.6), width: 1.2),
                ),
                child: Text(
                  aqiLevel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: aqiColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // AQI Multi-color Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 8,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00E676), // Green
                          Color(0xFFFFD600), // Yellow
                          Color(0xFFFF9100), // Orange
                          Color(0xFFFF3D00), // Red
                          Color(0xFF9C27B0), // Purple
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: (progress * (width - 14)).clamp(0.0, width - 14),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black45, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Advice Text
          Text(
            aqiAdvice,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),

          // Detailed Pollutants row (PM2.5, PM10)
          if (airQuality.pm25 != null || airQuality.pm10 != null) ...[
            const SizedBox(height: 14),
            Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (airQuality.pm25 != null)
                  _PollutantItem(
                    name: 'PM2.5',
                    value: '${airQuality.pm25!.toStringAsFixed(1)} µg/m³',
                  ),
                if (airQuality.pm10 != null)
                  _PollutantItem(
                    name: 'PM10',
                    value: '${airQuality.pm10!.toStringAsFixed(1)} µg/m³',
                  ),
                if (airQuality.ozone != null)
                  _PollutantItem(
                    name: 'Ozone (O₃)',
                    value: '${airQuality.ozone!.toStringAsFixed(1)} µg/m³',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PollutantItem extends StatelessWidget {
  final String name;
  final String value;

  const _PollutantItem({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
