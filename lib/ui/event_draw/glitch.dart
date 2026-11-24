import 'dart:math';

import 'package:flutter/material.dart';

/// One horizontal slice of a glitch layer, in fractions of the card height.
class GlitchSlice {
  const GlitchSlice(this.top, this.height, this.dx);

  final double top;
  final double height;

  /// Horizontal offset in logical pixels.
  final double dx;

  static GlitchSlice? random(Random r) {
    if (r.nextDouble() < 0.25) return null; // sometimes nothing: it flickers
    final top = r.nextDouble() * 0.8;
    return GlitchSlice(top, 0.04 + r.nextDouble() * 0.18, (r.nextDouble() - 0.5) * 26);
  }
}

class _SliceClipper extends CustomClipper<Rect> {
  _SliceClipper(this.slice);

  final GlitchSlice slice;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(
      0, size.height * slice.top, size.width, size.height * slice.height);

  @override
  bool shouldReclip(_SliceClipper old) => old.slice != slice;
}

/// A tinted, shifted copy of [child] limited to one horizontal [slice].
/// Two of them (pink + cyan) over the card make an RGB-split glitch.
class GlitchLayer extends StatelessWidget {
  const GlitchLayer({
    super.key,
    required this.slice,
    required this.tint,
    required this.child,
  });

  final GlitchSlice? slice;
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = slice;
    if (s == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(s.dx, 0),
        child: ClipRect(
          clipper: _SliceClipper(s),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
                tint.withValues(alpha: 0.55), BlendMode.srcATop),
            child: child,
          ),
        ),
      ),
    );
  }
}
