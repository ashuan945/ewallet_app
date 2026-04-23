import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class CreditScoreRing extends StatelessWidget {
  final int score;

  const CreditScoreRing({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(300, 850);
    final progress = (clampedScore - 300) / 550;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: _ScoreRingPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$clampedScore',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'out of 850',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _riskColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _riskLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _riskColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _riskLabel {
    if (score >= 740) return 'Low Risk';
    if (score >= 670) return 'Medium Risk';
    if (score >= 580) return 'High Risk';
    return 'Very High Risk';
  }

  Color get _riskColor {
    if (score >= 740) return AppTheme.accentGreen;
    if (score >= 670) return AppTheme.accentTeal;
    if (score >= 580) return AppTheme.accentOrange;
    return AppTheme.accentRed;
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;

  _ScoreRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    const strokeWidth = 14.0;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final bgPaint = Paint()
      ..color = AppTheme.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    final segments = [
      (const Color(0xFFe53935), 0.0, 0.25),
      (const Color(0xFFff9800), 0.25, 0.25),
      (const Color(0xFF00bfa5), 0.50, 0.25),
      (AppTheme.accentGreen, 0.75, 0.25),
    ];

    for (final (color, start, length) in segments) {
      final segmentPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + sweepAngle * start,
        sweepAngle * length * 0.92,
        false,
        segmentPaint,
      );
    }

    final progressPaint = Paint()
      ..color = AppTheme.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round;

    final currentSweep = sweepAngle * progress;
    if (currentSweep > 0.01) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        currentSweep,
        false,
        progressPaint,
      );
    }

    final dotAngle = startAngle + currentSweep;
    final dotCenter = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = AppTheme.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(dotCenter, 8, dotPaint);
    canvas.drawCircle(dotCenter, 8, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
