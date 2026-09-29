import 'dart:math';
import 'package:flutter/material.dart';
import '../models/weather.dart';
import 'glass_card.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> dailyList;
  final bool isCelsius;

  const DailyForecastWidget({
    super.key,
    required this.dailyList,
    required this.isCelsius,
  });

  String _formatTemp(double celsius) {
    if (isCelsius) {
      return '${celsius.round()}°';
    } else {
      final fahrenheit = (celsius * 9 / 5) + 32;
      return '${fahrenheit.round()}°';
    }
  }

  String _formatDayName(DateTime dt, bool isToday) {
    if (isToday) return 'Hôm nay';
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return weekdays[dt.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (dailyList.isEmpty) return const SizedBox.shrink();

    // Compute min and max across all days for proportional bar rendering
    double overallMin = dailyList.map((e) => e.tempMin).reduce(min);
    double overallMax = dailyList.map((e) => e.tempMax).reduce(max);
    if (overallMax == overallMin) overallMax += 1;

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                'DỰ BÁO 7 NGÀY TỚI',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Daily items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyList.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.white.withValues(alpha: 0.12),
              height: 16,
              thickness: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = dailyList[index];
              final isToday = index == 0;
              final dayName = _formatDayName(item.date, isToday);

              // Calculate bar relative positions (0.0 to 1.0)
              final leftPercent = ((item.tempMin - overallMin) / (overallMax - overallMin)).clamp(0.0, 1.0);
              final rightPercent = ((item.tempMax - overallMin) / (overallMax - overallMin)).clamp(0.0, 1.0);

              return Row(
                children: [
                  // Day name
                  SizedBox(
                    width: 90,
                    child: Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),

                  // Weather icon + Rain probability
                  SizedBox(
                    width: 55,
                    child: Row(
                      children: [
                        Icon(
                          FullWeatherData.getWeatherIcon(item.weatherCode, isDay: true),
                          size: 24,
                          color: Colors.white,
                        ),
                        if (item.precipitationProbabilityMax >= 20) ...[
                          const SizedBox(width: 2),
                          Text(
                            '${item.precipitationProbabilityMax}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64B5F6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Min Temp
                  SizedBox(
                    width: 32,
                    child: Text(
                      _formatTemp(item.tempMin),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Relative Temperature Bar
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final barStart = leftPercent * width;
                        final barWidth = max(8.0, (rightPercent - leftPercent) * width);

                        return Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: barStart,
                                width: barWidth,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4FC3F7),
                                        Color(0xFFFFB74D),
                                        Color(0xFFFF7043),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Max Temp
                  SizedBox(
                    width: 32,
                    child: Text(
                      _formatTemp(item.tempMax),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
