import 'dart:math';
import 'package:flutter/material.dart';

/// A card that tilts in 3D perspective when pressed or based on pointer position.
/// Simulates a physical card floating above the surface.
class TiltCard extends StatefulWidget {
  final Widget child;
  final double tiltAngle; // max tilt in degrees
  final double elevation; // shadow elevation
  final double depth; // Z-offset when tilted
  final double borderRadius;
  final Color? shadowColor;
  final bool enabled;

  const TiltCard({
    super.key,
    required this.child,
    this.tiltAngle = 12.0,
    this.elevation = 8.0,
    this.depth = 20.0,
    this.borderRadius = 14.0,
    this.shadowColor,
    this.enabled = true,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> with SingleTickerProviderStateMixin {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _scale = 1.0;
  bool _pressed = false;
  late AnimationController _animCtrl;
  late Animation<double> _springAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _springAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent event) {
    if (!widget.enabled) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(event.position);
    final size = box.size;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final dx = (localPos.dx - centerX) / centerX;
    final dy = (localPos.dy - centerY) / centerY;

    setState(() {
      _tiltX = -dy * widget.tiltAngle * (pi / 180);
      _tiltY = dx * widget.tiltAngle * (pi / 180);
      _scale = 1.0;// was 1.02, capped to prevent overflow
    });
  }

  void _onPointerExit(PointerEvent event) {
    if (!widget.enabled) return;
    _resetTilt();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _pressed = true;
      _scale = 0.98;// less aggressive press shrink
    });
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _pressed = false;
      _scale = 1.0;
    });
    _resetTilt();
  }

  void _onTapCancel() {
    if (!widget.enabled) return;
    setState(() {
      _pressed = false;
      _scale = 1.0;
    });
    _resetTilt();
  }

  void _resetTilt() {
    _animCtrl.forward(from: 0.0);
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shadowColor = widget.shadowColor ?? const Color(0xFF00B8FF);

    return MouseRegion(
      onHover: _onPointerMove,
      onExit: _onPointerExit,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _springAnim,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateX(_tiltX * (1 - _springAnim.value))
                ..rotateY(_tiltY * (1 - _springAnim.value))
                ..translate(
                  0.0,
                  0.0,
                  _pressed ? -widget.depth / 2 : _scale > 1.0 ? -widget.depth : 0.0,
                )
                ..scale(_scale),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withOpacity(_pressed ? 0.3 : 0.15),
                      blurRadius: _pressed ? 20 : widget.elevation * 2,
                      spreadRadius: _pressed ? 4 : 2,
                      offset: Offset(
                        _tiltY * 5,
                        -_tiltX * 5,
                      ),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: widget.elevation,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// A 3D parallax stack that creates depth layers.
/// Each child is placed at a different Z distance, creating a parallax
/// effect when the device is tilted or pointer moves.
class ParallaxStack extends StatefulWidget {
  final List<Widget> layers;
  final double intensity;

  const ParallaxStack({
    super.key,
    required this.layers,
    this.intensity = 10.0,
  });

  @override
  State<ParallaxStack> createState() => _ParallaxStackState();
}

class _ParallaxStackState extends State<ParallaxStack> {
  double _dx = 0.0;
  double _dy = 0.0;

  void _onPointerMove(PointerEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(event.position);
    final size = box.size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    setState(() {
      _dx = (localPos.dx - centerX) / centerX;
      _dy = (localPos.dy - centerY) / centerY;
    });
  }

  void _onPointerExit(PointerEvent event) {
    setState(() {
      _dx = 0.0;
      _dy = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onPointerMove,
      onExit: _onPointerExit,
      child: Stack(
        children: List.generate(widget.layers.length, (i) {
          final depth = (i + 1) * widget.intensity;
          return Transform.translate(
            offset: Offset(_dx * depth, _dy * depth),
            child: widget.layers[i],
          );
        }),
      ),
    );
  }
}
