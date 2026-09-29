import 'package:flutter/material.dart';
import '../models/weather.dart';
import 'glass_card.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyList;
  final bool isCelsius;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyList,
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

  String _formatHour(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              const Icon(
                Icons.access_time_filled_rounded,
                size: 18,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                'DỰ BÁO THEO GIỜ (24H)',
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

          // Horizontal scrollable list
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: hourlyList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = hourlyList[index];
                final isNow = index == 0;
                final timeLabel = isNow ? 'Bây giờ' : _formatHour(item.time);

                return Container(
                  width: 66,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isNow
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isNow
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Time
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isNow ? FontWeight.bold : FontWeight.w500,
                          color: isNow ? Colors.white : Colors.white70,
                        ),
                      ),

                      // Weather Icon
                      Icon(
                        FullWeatherData.getWeatherIcon(
                          item.weatherCode,
                          isDay: item.isDay,
                        ),
                        size: 28,
                        color: Colors.white,
                      ),

                      // Rain Probability (if > 0%)
                      if (item.precipitationProbability > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.water_drop,
                              size: 10,
                              color: Color(0xFF64B5F6),
                            ),
                            Text(
                              '${item.precipitationProbability}%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF90CAF9),
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(height: 12),

                      // Temperature
                      Text(
                        _formatTemp(item.temperature),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
