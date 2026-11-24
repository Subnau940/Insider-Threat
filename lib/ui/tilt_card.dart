/// Makes any card "playable": it leans towards the finger (or the mouse) in
/// light 3D, with a soft glare, and springs back flat when released.
library;

import 'package:flutter/material.dart';

class Tilt3D extends StatefulWidget {
  const Tilt3D({
    super.key,
    required this.child,
    this.enabled = true,
    this.maxAngle = .22,
    this.radius = 18,
  });

  final Widget child;

  /// Off while another animation (draw, flip) moves the card.
  final bool enabled;

  /// Largest lean, in radians (about 12°).
  final double maxAngle;

  /// Corner radius of the card, for the glare.
  final double radius;

  @override
  State<Tilt3D> createState() => _Tilt3DState();
}

class _Tilt3DState extends State<Tilt3D> with SingleTickerProviderStateMixin {
  /// Finger position on the card, -1..1 on both axes (0, 0 = centre).
  Offset _tilt = Offset.zero;
  Offset _from = Offset.zero;
  bool _held = false;

  late final AnimationController _back = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..addListener(() {
      final t = Curves.easeOutBack.transform(_back.value);
      setState(() => _tilt = Offset.lerp(_from, Offset.zero, t)!);
    });

  @override
  void didUpdateWidget(Tilt3D old) {
    super.didUpdateWidget(old);
    if (!widget.enabled && _tilt != Offset.zero) {
      _back.stop();
      _held = false;
      _tilt = Offset.zero;
    }
  }

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  void _track(Offset local) {
    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final size = box.size;
    if (size.isEmpty) return;
    _back.stop();
    setState(() {
      _held = true;
      _tilt = Offset(
        (local.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
        (local.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
      );
    });
  }

  void _release() {
    if (!_held) return;
    _held = false;
    _from = _tilt;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final strength = (_tilt.distance / 1.41).clamp(0.0, 1.0);
    final scale = 1 + .03 * strength;
    final card = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, .0015)
        // The pressed side goes away from the viewer.
        ..rotateX(_tilt.dy * widget.maxAngle)
        ..rotateY(-_tilt.dx * widget.maxAngle)
        ..scaleByDouble(scale, scale, 1, 1),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (strength > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.radius),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        // The light sits opposite the pressed side.
                        center: Alignment(-_tilt.dx, -_tilt.dy),
                        radius: .9,
                        colors: [
                          Colors.white.withValues(alpha: .16 * strength),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    // Listener, not a gesture detector: the card never steals a scroll or a tap.
    return MouseRegion(
      onHover: (e) => _track(e.localPosition),
      onExit: (_) => _release(),
      child: Listener(
        onPointerDown: (e) => _track(e.localPosition),
        onPointerMove: (e) => _track(e.localPosition),
        onPointerUp: (_) => _release(),
        onPointerCancel: (_) => _release(),
        child: card,
      ),
    );
  }
}
