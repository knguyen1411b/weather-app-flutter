import 'dart:math';
import 'package:flutter/material.dart';
import '../models/weather.dart';

class WeatherBackground extends StatefulWidget {
  final Weather? weather;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.weather,
    required this.child,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.5 + 0.2,
        opacity: _random.nextDouble() * 0.6 + 0.2,
      ));
    }
  }

  @override
  void didUpdateWidget(WeatherBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weather?.weatherCode != widget.weather?.weatherCode ||
        oldWidget.weather?.isDay != widget.weather?.isDay) {
      _initParticles();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.weather?.weatherCode ?? 0;
    final isDay = widget.weather?.isDayTime ?? true;
    final gradientColors = FullWeatherData.getWeatherGradients(code, isDay: isDay);

    return Stack(
      children: [
        // Dynamic background gradient
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
        ),

        // Ambient weather particle canvas
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return CustomPaint(
              painter: _WeatherParticlePainter(
                particles: _particles,
                progress: _animController.value,
                code: code,
                isDay: isDay,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _WeatherParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final int code;
  final bool isDay;

  _WeatherParticlePainter({
    required this.particles,
    required this.progress,
    required this.code,
    required this.isDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Rain effect
    if (code >= 51 && code <= 67 || (code >= 80 && code <= 82)) {
      paint.color = Colors.white.withValues(alpha: 0.35);
      paint.strokeWidth = 1.5;
      paint.strokeCap = StrokeCap.round;

      for (var p in particles) {
        final currentY = ((p.y + progress * (p.speed * 4)) % 1.0) * size.height;
        final currentX = ((p.x + progress * 0.1) % 1.0) * size.width;

        canvas.drawLine(
          Offset(currentX, currentY),
          Offset(currentX - 4, currentY + 16),
          paint,
        );
      }
      return;
    }

    // Snow effect
    if (code >= 71 && code <= 77 || code == 85 || code == 86) {
      for (var p in particles) {
        final currentY = ((p.y + progress * p.speed) % 1.0) * size.height;
        final currentX = ((p.x + sin(progress * 2 * pi + p.x * 10) * 0.05) % 1.0) * size.width;

        paint.color = Colors.white.withValues(alpha: p.opacity);
        canvas.drawCircle(Offset(currentX, currentY), p.size * 1.5, paint);
      }
      return;
    }

    // Clear night - Stars twinkling
    if (!isDay && code <= 2) {
      for (var p in particles) {
        final twinkle = (sin((progress + p.x) * 2 * pi) + 1) / 2;
        final currentY = p.y * size.height * 0.6; // Stars in upper sky
        final currentX = p.x * size.width;

        paint.color = Colors.white.withValues(alpha: (p.opacity * 0.7) + (twinkle * 0.3));
        canvas.drawCircle(Offset(currentX, currentY), p.size, paint);
      }
      return;
    }

    // Sunny Day - Ambient light sparkles
    if (isDay && code <= 1) {
      for (var p in particles) {
        final pulse = (sin((progress + p.y) * 2 * pi) + 1) / 2;
        final currentY = ((p.y - progress * 0.2) % 1.0) * size.height;
        final currentX = ((p.x + sin(progress * pi + p.x * 5) * 0.03) % 1.0) * size.width;

        paint.color = Colors.white.withValues(alpha: p.opacity * 0.25 * pulse);
        canvas.drawCircle(Offset(currentX, currentY), p.size * 2, paint);
      }
      return;
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherParticlePainter oldDelegate) => true;
}
