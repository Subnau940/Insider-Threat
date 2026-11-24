/// Back and front of an Event card, styled like the printed card.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../game/events.dart';
import '../../theme/app_theme.dart';

const kCardPanel = Color(0xFF0E1420);
const kCardLime = Color(0xFFCCF500);
const kCardMuted = Color(0xFF6B7690);

/// Standard card, width / height.
const kCardRatio = 63 / 88;

extension EventSideStyle on EventSide {
  Color get color => switch (this) {
        EventSide.blue => const Color(0xFF3B6BFF),
        EventSide.red => const Color(0xFFFF3D5A),
        EventSide.chaos => kCardLime,
      };

  /// Text colour on top of [color].
  Color get ink => this == EventSide.chaos ? kCardPanel : Colors.white;
}

TextStyle cardInter({
  required double size,
  Color color = Colors.white,
  FontWeight weight = FontWeight.w400,
  double? height,
  double? spacing,
  FontStyle? style,
}) {
  final base = TextStyle(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
    letterSpacing: spacing,
    fontStyle: style,
  );
  return AppText.useGoogleFonts ? GoogleFonts.inter(textStyle: base) : base;
}

TextStyle cardMono({required double size, Color color = kCardLime, double? spacing}) {
  final base = TextStyle(fontSize: size, color: color, letterSpacing: spacing);
  return AppText.useGoogleFonts ? GoogleFonts.jetBrainsMono(textStyle: base) : base;
}

/// Maps [t] (0..1) into the [a]..[b] window, eased. Used for staggered reveals.
double interval(double t, double a, double b, [Curve curve = Curves.easeOutCubic]) =>
    curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0).toDouble());

/// Dark grid background shared by both faces.
class GridPainter extends CustomPainter {
  GridPainter(this.step, {this.color = const Color(0x177896C8)});

  final double step;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(GridPainter old) => old.step != step || old.color != color;
}

class _FaceShell extends StatelessWidget {
  const _FaceShell({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: width / kCardRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ColoredBox(
            color: kCardPanel,
            child: Stack(children: [
              Positioned.fill(
                  child: CustomPaint(painter: GridPainter(width / 15.75))),
              Positioned.fill(child: child),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      );
}

class CardBack extends StatelessWidget {
  const CardBack({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final mono = cardMono(size: width * 0.03, spacing: 1.5);
    Widget corner(Alignment a) {
      final top = a.y < 0, left = a.x < 0;
      const side = BorderSide(color: kCardLime, width: 2);
      return Align(
        alignment: a,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              border: Border(
                top: top ? side : BorderSide.none,
                bottom: top ? BorderSide.none : side,
                left: left ? side : BorderSide.none,
                right: left ? BorderSide.none : side,
              ),
            ),
          ),
        ),
      );
    }

    return _FaceShell(
      width: width,
      child: Stack(children: [
        corner(Alignment.topLeft),
        corner(Alignment.topRight),
        corner(Alignment.bottomLeft),
        corner(Alignment.bottomRight),
        Align(
          alignment: const Alignment(0, -0.7),
          child: Text('> CORP-LAN // INCOMING', style: mono),
        ),
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              'INSIDER\nTHREAT',
              textAlign: TextAlign.center,
              style: cardInter(
                  size: width * 0.13, height: 0.95, weight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
              decoration: BoxDecoration(
                  color: kCardLime, borderRadius: BorderRadius.circular(4)),
              child: Text('EVENT',
                  style: cardInter(
                      size: 12,
                      color: kCardPanel,
                      weight: FontWeight.w800,
                      spacing: 1.2)),
            ),
          ]),
        ),
        Align(
          alignment: const Alignment(0, 0.8),
          child: Text('EXPERT MODE',
              style: cardMono(
                  size: width * 0.027, color: kCardMuted, spacing: 1.5)),
        ),
      ]),
    );
  }
}

/// [reveal] (0..1) drives the staggered entrance of each block. [title] is
/// passed separately so the panel can decode it letter by letter.
class CardFront extends StatelessWidget {
  const CardFront({
    super.key,
    required this.card,
    required this.width,
    required this.title,
    this.reveal = 1,
  });

  final EventCard card;
  final double width;
  final String title;
  final double reveal;

  List<TextSpan> _rich(String text, TextStyle base, TextStyle bold) {
    final parts = text.split('**');
    return [
      for (var i = 0; i < parts.length; i++)
        TextSpan(text: parts[i], style: i.isOdd ? bold : base),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final w = width, h = width / kCardRatio;
    final info = card.info;
    final face = card.face;
    final side = info.side;
    final number = info.number.toString().padLeft(2, '0');
    final t = reveal;

    final band = interval(t, 0.0, 0.25);
    final numP = interval(t, 0.05, 0.35);
    final bar = interval(t, 0.55, 0.75);
    final flavor = interval(t, 0.6, 0.8);
    final tag = interval(t, 0.68, 0.88, Curves.easeOutBack);
    final effect = interval(t, 0.75, 1.0);

    Widget fadeUp(double p, Widget child) => Opacity(
          opacity: p.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(offset: Offset(0, 8 * (1 - p)), child: child),
        );

    final effectBase = cardInter(size: w * 0.047, height: 1.38);

    return _FaceShell(
      width: w,
      child: Stack(children: [
        // big number watermark
        Positioned(
          right: w * 0.04,
          bottom: h * 0.12,
          child: Opacity(
            opacity: 0.13 * numP,
            child: Transform.scale(
              scale: 1.4 - 0.4 * numP,
              child: Text(number,
                  style: cardInter(
                      size: w * 0.5,
                      color: side.color,
                      weight: FontWeight.w900,
                      height: 1)),
            ),
          ),
        ),
        // Content is clipped rather than overflowing if a text runs long.
        Positioned.fill(
          bottom: h * 0.09,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minHeight: 0,
              maxHeight: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // coloured band, slides down from the top
                  ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: band,
                      child: Container(
                        height: h * 0.11,
                        width: double.infinity,
                        color: side.color,
                        padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'EVENT $number // ${info.side.label.toUpperCase()}',
                            style: cardInter(
                                size: w * 0.036,
                                color: side.ink,
                                weight: FontWeight.w800,
                                spacing: 0.5)),
                      ),
                    ),
                  ),
                  if (band < 1) SizedBox(height: h * 0.11 * (1 - band)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(w * 0.06, w * 0.06, w * 0.06, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: cardInter(
                                size: w * 0.078,
                                weight: FontWeight.w900,
                                height: 1.08)),
                        SizedBox(height: w * 0.03),
                        Transform.scale(
                          scaleX: bar < 0.001 ? 0.001 : bar,
                          alignment: Alignment.centerLeft,
                          child: Container(
                              width: w * 0.2, height: 3, color: side.color),
                        ),
                        SizedBox(height: w * 0.045),
                        fadeUp(
                          flavor,
                          Text(face.flavor,
                              style: cardInter(
                                  size: w * 0.038,
                                  color: const Color(0xFFAAB4C3),
                                  style: FontStyle.italic,
                                  height: 1.35)),
                        ),
                        SizedBox(height: w * 0.055),
                        Opacity(
                          opacity: tag.clamp(0.0, 1.0).toDouble(),
                          child: Transform.scale(
                            scale: 0.6 + 0.4 * tag,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  color: side.color,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(face.when,
                                  style: cardInter(
                                      size: w * 0.033,
                                      color: side.ink,
                                      weight: FontWeight.w800,
                                      spacing: 0.6)),
                            ),
                          ),
                        ),
                        SizedBox(height: w * 0.04),
                        fadeUp(
                          effect,
                          Text.rich(TextSpan(
                            children: _rich(
                              face.effect,
                              effectBase,
                              effectBase.copyWith(
                                  color: side.color,
                                  fontWeight: FontWeight.w700),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // footer
        Positioned(
          left: w * 0.06,
          right: w * 0.06,
          bottom: h * 0.035,
          child: Row(children: [
            Expanded(
              child: Text('INSIDER THREAT // EXPERT MODE',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: cardMono(
                      size: w * 0.026, color: kCardMuted, spacing: 0.6)),
            ),
            for (var i = 0; i < 3; i++)
              Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 3),
                  color: side.color),
          ]),
        ),
      ]),
    );
  }
}
