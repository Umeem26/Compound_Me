import 'dart:math' as math;

import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:flutter/material.dart';

/// The three value pages of onboarding (S-01).
enum OnboardingArtKind { growth, speed, privacy }

/// Simple one-color line drawings on a tinted circle (S-01: `primary` plus
/// one `accent` detail, no characters). Geometry is proportional to the
/// canvas so the art scales with [AppSizes.onboardingArt].
class OnboardingArt extends StatelessWidget {
  const OnboardingArt({required this.kind, super.key});

  final OnboardingArtKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: AppSizes.onboardingArt,
        child: CustomPaint(
          painter: _ArtPainter(
            kind: kind,
            circle: colors.primaryTint,
            line: colors.primary,
            fill: colors.surface,
            accent: colors.accent,
            onAccent: colors.onAccent,
          ),
        ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  const _ArtPainter({
    required this.kind,
    required this.circle,
    required this.line,
    required this.fill,
    required this.accent,
    required this.onAccent,
  });

  final OnboardingArtKind kind;
  final Color circle;
  final Color line;
  final Color fill;
  final Color accent;
  final Color onAccent;

  static const double _stroke = AppSizes.borderSelected;

  Paint get _linePaint => Paint()
    ..color = line
    ..style = PaintingStyle.stroke
    ..strokeWidth = _stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint _markPaint(double width) => Paint()
    ..color = onAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2, Paint()..color = circle);
    switch (kind) {
      case OnboardingArtKind.growth:
        _growth(canvas, s);
      case OnboardingArtKind.speed:
        _speed(canvas, s);
      case OnboardingArtKind.privacy:
        _privacy(canvas, s);
    }
  }

  /// Small steps that add up: dots growing along a dotted line toward a
  /// gold "+" (mockup S-01).
  void _growth(Canvas canvas, double s) {
    canvas.drawLine(
      Offset(s * 0.22, s * 0.74),
      Offset(s * 0.78, s * 0.74),
      _linePaint..color = line.withValues(alpha: AppOpacity.disabled),
    );
    final small = Offset(s * 0.3, s * 0.66);
    final medium = Offset(s * 0.48, s * 0.58);
    final gold = Offset(s * 0.7, s * 0.36);
    _dotted(canvas, small, medium, s);
    _dotted(canvas, medium, gold, s);
    for (final (center, radius) in [(small, s * 0.035), (medium, s * 0.052)]) {
      canvas
        ..drawCircle(center, radius, Paint()..color = fill)
        ..drawCircle(center, radius, _linePaint);
    }
    final r = s * 0.085;
    canvas.drawCircle(gold, r, Paint()..color = accent);
    final arm = r * 0.45;
    final mark = _markPaint(_stroke * 1.5);
    canvas
      ..drawLine(gold - Offset(arm, 0), gold + Offset(arm, 0), mark)
      ..drawLine(gold - Offset(0, arm), gold + Offset(0, arm), mark);
  }

  /// Fast logging: a keypad grid with a gold check.
  void _speed(Canvas canvas, double s) {
    final key = s * 0.1;
    final gap = s * 0.035;
    final grid = key * 3 + gap * 2;
    final origin = Offset(s * 0.44 - grid / 2, s * 0.6 - grid / 2);
    final radius = Radius.circular(key * 0.25);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        final topLeft = origin + Offset(col * (key + gap), row * (key + gap));
        final rect = RRect.fromRectAndRadius(
          topLeft & Size.square(key),
          radius,
        );
        canvas
          ..drawRRect(rect, Paint()..color = fill)
          ..drawRRect(rect, _linePaint);
      }
    }
    final gold = Offset(s * 0.7, s * 0.34);
    final r = s * 0.085;
    canvas.drawCircle(gold, r, Paint()..color = accent);
    final check = Path()
      ..moveTo(gold.dx - r * 0.4, gold.dy)
      ..lineTo(gold.dx - r * 0.1, gold.dy + r * 0.3)
      ..lineTo(gold.dx + r * 0.42, gold.dy - r * 0.3);
    canvas.drawPath(check, _markPaint(_stroke * 1.5));
  }

  /// Private on the device: a phone outline holding a gold lock.
  void _privacy(Canvas canvas, double s) {
    final phone = RRect.fromLTRBR(
      s * 0.34,
      s * 0.22,
      s * 0.66,
      s * 0.8,
      Radius.circular(s * 0.05),
    );
    canvas
      ..drawRRect(phone, Paint()..color = fill)
      ..drawRRect(phone, _linePaint)
      ..drawLine(
        Offset(s * 0.46, s * 0.27),
        Offset(s * 0.54, s * 0.27),
        _linePaint,
      );
    final gold = Offset(s * 0.5, s * 0.52);
    final r = s * 0.1;
    canvas.drawCircle(gold, r, Paint()..color = accent);
    final mark = _markPaint(_stroke * 1.25);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: gold + Offset(0, r * 0.18),
        width: r * 0.9,
        height: r * 0.7,
      ),
      Radius.circular(r * 0.12),
    );
    canvas
      ..drawRRect(body, mark)
      ..drawArc(
        Rect.fromCenter(
          center: gold - Offset(0, r * 0.2),
          width: r * 0.55,
          height: r * 0.6,
        ),
        math.pi,
        math.pi,
        false,
        mark,
      );
  }

  void _dotted(Canvas canvas, Offset from, Offset to, double s) {
    final paint = Paint()..color = line;
    final step = s * 0.03;
    final distance = (to - from).distance;
    final count = (distance / step).floor();
    for (var i = 1; i < count; i++) {
      canvas.drawCircle(
        Offset.lerp(from, to, i / count)!,
        _stroke * 0.75,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArtPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.circle != circle ||
      oldDelegate.line != line ||
      oldDelegate.fill != fill ||
      oldDelegate.accent != accent ||
      oldDelegate.onAccent != onAccent;
}
