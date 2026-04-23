import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SelfieFrame extends StatelessWidget {
  final Uint8List? capturedImage;
  final bool showPreview;

  const SelfieFrame({super.key, this.capturedImage, this.showPreview = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showPreview && capturedImage != null)
              Image.memory(
                capturedImage!,
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkBackground,
                      AppTheme.darkBackground.withOpacity(0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            if (!showPreview) ...[
              CustomPaint(
                size: const Size(280, 340),
                painter: _FaceOvalPainter(),
              ),
              Positioned(
                bottom: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.face, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Position your face within the frame',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaceOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 10),
      width: 200,
      height: 260,
    );

    canvas.drawOval(ovalRect, paint);

    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const cornerLength = 20.0;
    final corners = [
      (ovalRect.left, ovalRect.top, 1, 1),
      (ovalRect.right, ovalRect.top, -1, 1),
      (ovalRect.left, ovalRect.bottom, 1, -1),
      (ovalRect.right, ovalRect.bottom, -1, -1),
    ];

    for (final (x, y, dx, dy) in corners) {
      final path = Path()
        ..moveTo(x + cornerLength * dx, y)
        ..lineTo(x, y)
        ..lineTo(x, y + cornerLength * dy);
      canvas.drawPath(path, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
