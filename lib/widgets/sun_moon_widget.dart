import 'dart:math';
import 'package:flutter/material.dart';
import 'glass_card.dart';

class SunMoonWidget extends StatelessWidget {
  final DateTime? sunrise;
  final DateTime? sunset;

  const SunMoonWidget({
    super.key,
    required this.sunrise,
    required this.sunset,
  });

  String _formatHour(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (sunrise == null || sunset == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final sunriseStr = _formatHour(sunrise!);
    final sunsetStr = _formatHour(sunset!);

    // Calculate progress between sunrise and sunset
    double progress = 0.0;
    String statusText = '';

    if (now.isBefore(sunrise!)) {
      progress = 0.0;
      final diff = sunrise!.difference(now);
      statusText = 'Mặt trời mọc sau ${diff.inHours}h ${diff.inMinutes % 60}m';
    } else if (now.isAfter(sunset!)) {
      progress = 1.0;
      statusText = 'Mặt trời đã lặn';
    } else {
      final totalDayDuration = sunset!.difference(sunrise!).inSeconds;
      final elapsedDuration = now.difference(sunrise!).inSeconds;
      progress = (elapsedDuration / totalDayDuration).clamp(0.0, 1.0);
      final remaining = sunset!.difference(now);
      statusText = 'Còn ${remaining.inHours}h ${remaining.inMinutes % 60}m nắng';
    }

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
                Icons.wb_twilight_rounded,
                size: 18,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                'MẶT TRỜI MỌC & LẶN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Arch canvas
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _SunArcPainter(progress: progress),
            ),
          ),

          // Sunrise & Sunset Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bình minh',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  Text(
                    sunriseStr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.9),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Hoàng hôn',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  Text(
                    sunsetStr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;

  _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h + 10);
    final radius = w * 0.44;

    // Horizon line
    final horizonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, h - 10), Offset(w, h - 10), horizonPaint);

    // Dashed Sun Arc path
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, pi, pi, false, arcPaint);

    // Sun current position along the arc (pi to 2*pi)
    final angle = pi + (progress * pi);
    final sunX = center.dx + radius * cos(angle);
    final sunY = center.dy + radius * sin(angle);

    // Glow aura
    final glowPaint = Paint()
      ..color = const Color(0xFFFFB300).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(sunX, sunY), 14, glowPaint);

    // Sun disk
    final sunPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 7, sunPaint);
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
