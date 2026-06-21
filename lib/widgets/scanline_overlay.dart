import 'dart:math';
import 'package:flutter/material.dart';

/// CRT Scanline overlay that gives the classic retro-futuristic monitor effect.
/// Draws horizontal lines and subtle noise to simulate a CRT display.
class ScanlineOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double lineThickness;
  final double lineSpacing;
  final bool showNoise;
  final bool showVignette;

  const ScanlineOverlay({
    super.key,
    required this.child,
    this.opacity = 0.03,
    this.lineThickness = 1.0,
    this.lineSpacing = 3.0,
    this.showNoise = true,
    this.showVignette = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Scanlines
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinePainter(
                lineThickness: lineThickness,
                lineSpacing: lineSpacing,
                opacity: opacity,
                showVignette: showVignette,
              ),
            ),
          ),
        ),
        // Flicker / noise overlay
        if (showNoise)
          Positioned.fill(
            child: IgnorePointer(
              child: _NoiseOverlay(opacity: opacity * 2),
            ),
          ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double lineThickness;
  final double lineSpacing;
  final double opacity;
  final bool showVignette;

  _ScanlinePainter({
    required this.lineThickness,
    required this.lineSpacing,
    required this.opacity,
    required this.showVignette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scanlines
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..strokeWidth = lineThickness;

    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      y += lineSpacing;
    }

    // Vignette effect (dark corners)
    if (showVignette) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: 0.4),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      canvas.drawRect(
        rect,
        Paint()..shader = gradient.createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) => false;
}

class _NoiseOverlay extends StatefulWidget {
  final double opacity;
  const _NoiseOverlay({required this.opacity});

  @override
  State<_NoiseOverlay> createState() => _NoiseOverlayState();
}

class _NoiseOverlayState extends State<_NoiseOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _NoisePainter(
            opacity: widget.opacity,
            seed: _random.nextInt(1000),
          ),
        );
      },
    );
  }
}

class _NoisePainter extends CustomPainter {
  final double opacity;
  final int seed;

  _NoisePainter({required this.opacity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint();
    const blockSize = 4.0;

    for (double x = 0; x < size.width; x += blockSize) {
      for (double y = 0; y < size.height; y += blockSize) {
        if (random.nextDouble() > 0.85) {
          paint.color = Colors.white.withOpacity(
            opacity * random.nextDouble(),
          );
          canvas.drawRect(
            Rect.fromLTWH(x, y, blockSize, blockSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) => true;
}
