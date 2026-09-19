// Original programmatic icon set. Vector strokes drawn with CustomPainter so
// the HUD, Codex and panels share one coherent style and stay readable in
// grayscale (status is never color-only).
import 'package:flutter/material.dart';

enum IronIconKind {
  hydration,
  fatigue,
  quest,
  interaction,
  codex,
  press,
  isolation,
  recovery,
  locked,
  xp,
  check,
  menu,
}

class IronIcon extends StatelessWidget {
  const IronIcon(this.kind, {super.key, this.size = 20, this.color});
  final IronIconKind kind;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.white;
    return Semantics(
      label: kind.name,
      child: CustomPaint(
        size: Size.square(size),
        painter: _IronIconPainter(kind, c),
      ),
    );
  }
}

class _IronIconPainter extends CustomPainter {
  _IronIconPainter(this.kind, this.color);
  final IronIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    Offset p(double x, double y) => Offset(x * s, y * s);

    switch (kind) {
      case IronIconKind.hydration:
        final path = Path()
          ..moveTo(s * 0.5, s * 0.08)
          ..cubicTo(s * 0.5, s * 0.3, s * 0.18, s * 0.45, s * 0.18, s * 0.66)
          ..arcToPoint(p(0.82, 0.66), radius: Radius.circular(s * 0.32))
          ..cubicTo(s * 0.82, s * 0.45, s * 0.5, s * 0.3, s * 0.5, s * 0.08)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawLine(
          p(0.36, 0.7),
          p(0.44, 0.8),
          stroke
            ..color = Colors.black.withValues(alpha: 0.35)
            ..strokeWidth = s * 0.07,
        );
      case IronIconKind.fatigue:
        final path = Path()
          ..moveTo(s * 0.58, s * 0.06)
          ..lineTo(s * 0.22, s * 0.56)
          ..lineTo(s * 0.48, s * 0.56)
          ..lineTo(s * 0.4, s * 0.94)
          ..lineTo(s * 0.78, s * 0.42)
          ..lineTo(s * 0.52, s * 0.42)
          ..close();
        canvas.drawPath(path, fill);
      case IronIconKind.quest:
        canvas.drawLine(p(0.25, 0.1), p(0.25, 0.92), stroke);
        final flag = Path()
          ..moveTo(s * 0.28, s * 0.14)
          ..lineTo(s * 0.8, s * 0.14)
          ..lineTo(s * 0.66, s * 0.34)
          ..lineTo(s * 0.8, s * 0.54)
          ..lineTo(s * 0.28, s * 0.54)
          ..close();
        canvas.drawPath(flag, fill);
      case IronIconKind.interaction:
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.12, s * 0.12, s * 0.76, s * 0.76),
          Radius.circular(s * 0.14),
        );
        canvas.drawRRect(r, stroke);
        canvas.drawLine(p(0.34, 0.5), p(0.66, 0.5), stroke);
        canvas.drawLine(p(0.5, 0.34), p(0.5, 0.66), stroke);
      case IronIconKind.codex:
        final book = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.16, s * 0.1, s * 0.68, s * 0.8),
          Radius.circular(s * 0.06),
        );
        canvas.drawRRect(book, stroke);
        canvas.drawLine(p(0.3, 0.1), p(0.3, 0.9), stroke);
        canvas.drawLine(p(0.44, 0.32), p(0.72, 0.32), stroke);
        canvas.drawLine(p(0.44, 0.5), p(0.72, 0.5), stroke);
      case IronIconKind.press:
        // Barbell with an upward arrow: pressing.
        canvas.drawLine(p(0.1, 0.72), p(0.9, 0.72), stroke);
        canvas.drawRect(
          Rect.fromLTWH(s * 0.1, s * 0.58, s * 0.14, s * 0.28),
          fill,
        );
        canvas.drawRect(
          Rect.fromLTWH(s * 0.76, s * 0.58, s * 0.14, s * 0.28),
          fill,
        );
        canvas.drawLine(p(0.5, 0.5), p(0.5, 0.12), stroke);
        canvas.drawLine(p(0.34, 0.28), p(0.5, 0.12), stroke);
        canvas.drawLine(p(0.66, 0.28), p(0.5, 0.12), stroke);
      case IronIconKind.isolation:
        // Two cables converging: adduction / isolation.
        final left = Path()
          ..moveTo(s * 0.12, s * 0.16)
          ..quadraticBezierTo(s * 0.2, s * 0.7, s * 0.5, s * 0.84);
        final right = Path()
          ..moveTo(s * 0.88, s * 0.16)
          ..quadraticBezierTo(s * 0.8, s * 0.7, s * 0.5, s * 0.84);
        canvas.drawPath(left, stroke);
        canvas.drawPath(right, stroke);
        canvas.drawCircle(p(0.12, 0.16), s * 0.08, fill);
        canvas.drawCircle(p(0.88, 0.16), s * 0.08, fill);
      case IronIconKind.recovery:
        // Leaf / mat: calm recovery.
        final leaf = Path()
          ..moveTo(s * 0.18, s * 0.82)
          ..quadraticBezierTo(s * 0.12, s * 0.3, s * 0.82, s * 0.18)
          ..quadraticBezierTo(s * 0.7, s * 0.88, s * 0.18, s * 0.82)
          ..close();
        canvas.drawPath(leaf, stroke);
        canvas.drawLine(p(0.22, 0.78), p(0.68, 0.32), stroke);
      case IronIconKind.locked:
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.2, s * 0.44, s * 0.6, s * 0.46),
          Radius.circular(s * 0.08),
        );
        canvas.drawRRect(body, fill);
        final shackle = Path()
          ..moveTo(s * 0.32, s * 0.44)
          ..lineTo(s * 0.32, s * 0.3)
          ..arcToPoint(p(0.68, 0.3), radius: Radius.circular(s * 0.18))
          ..lineTo(s * 0.68, s * 0.44);
        canvas.drawPath(shackle, stroke);
      case IronIconKind.xp:
        // Rising chevrons: progression.
        for (var i = 0; i < 2; i++) {
          final y = 0.42 + i * 0.3;
          final path = Path()
            ..moveTo(s * 0.18, s * (y + 0.16))
            ..lineTo(s * 0.5, s * (y - 0.14))
            ..lineTo(s * 0.82, s * (y + 0.16));
          canvas.drawPath(path, stroke);
        }
      case IronIconKind.check:
        final path = Path()
          ..moveTo(s * 0.18, s * 0.52)
          ..lineTo(s * 0.42, s * 0.76)
          ..lineTo(s * 0.84, s * 0.26);
        canvas.drawPath(path, stroke);
      case IronIconKind.menu:
        for (var i = 0; i < 3; i++) {
          final y = 0.26 + i * 0.24;
          canvas.drawLine(p(0.16, y), p(0.84, y), stroke);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _IronIconPainter old) =>
      old.kind != kind || old.color != color;
}
