import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Brand logo widget combining the custom BorrowIT vector icon and "BorrowIT" wordmark.
class BorrowItLogo extends StatelessWidget {
  final bool compact;

  final bool onDark;

  const BorrowItLogo({super.key, this.compact = false, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? 20.0 : 30.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BorrowItMark(size: compact ? 32 : 44),
        SizedBox(width: compact ? 10 : 12),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.0,
                ),
            children: [
              TextSpan(
                text: 'Borrow',
                style: TextStyle(
                  color: onDark ? Colors.white : AppColors.darkText,
                ),
              ),
              TextSpan(
                text: 'IT',
                style: TextStyle(
                  color: onDark ? AppColors.brightGold : AppColors.universityRed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom-painted vector icon showing a 3D gold equipment box inside a maroon return arrow.
class BorrowItMark extends StatelessWidget {
  final double size;
  final bool glow;

  const BorrowItMark({super.key, this.size = 44, this.glow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.universityRed.withValues(alpha: 0.35),
                  blurRadius: size * 0.45,
                  offset: Offset(0, size * 0.12),
                ),
              ]
            : null,
      ),
      child: CustomPaint(painter: _BorrowItMarkPainter()),
    );
  }
}

class _BorrowItMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;
    final tile = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.28));

    canvas.drawRRect(
      tile,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA62550), Color(0xFF7A132F), Color(0xFF4E0A1E)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipRRect(tile);
    final glossCenter = Offset(s * 0.18, s * 0.02);
    canvas.drawCircle(
      glossCenter,
      s * 0.65,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.24),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: glossCenter, radius: s * 0.65)),
    );
    canvas.restore();

    canvas.drawRRect(
      tile.deflate(s * 0.014),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.026
        ..color = AppColors.brightGold.withValues(alpha: 0.55),
    );

    final c = Offset(s / 2, s / 2);

    final r = s * 0.335;
    const gap = 0.55;
    const start = -math.pi / 2 + gap;
    const sweep = 2 * math.pi - gap * 2;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.052
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.94),
    );

    const end = start + sweep;
    final normal = Offset(math.cos(end), math.sin(end));
    final dir = Offset(-math.sin(end), math.cos(end));
    final endPt = c + normal * r;
    final base = endPt - dir * (s * 0.01);
    final tip = endPt + dir * (s * 0.085);
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((base + normal * s * 0.068).dx, (base + normal * s * 0.068).dy)
      ..lineTo((base - normal * s * 0.068).dx, (base - normal * s * 0.068).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = Colors.white.withValues(alpha: 0.94));

    final a = s * 0.175;
    final k = a * 0.866;
    final top = Offset(c.dx, c.dy - a);
    final right = Offset(c.dx + k, c.dy - a / 2);
    final left = Offset(c.dx - k, c.dy - a / 2);
    final bottom = Offset(c.dx, c.dy + a);
    final bottomLeft = Offset(c.dx - k, c.dy + a / 2);
    final bottomRight = Offset(c.dx + k, c.dy + a / 2);

    Path face(List<Offset> pts) {
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final pt in pts.skip(1)) {
        p.lineTo(pt.dx, pt.dy);
      }
      return p..close();
    }

    final topFace = face([top, right, c, left]);
    final leftFace = face([left, c, bottom, bottomLeft]);
    final rightFace = face([c, right, bottomRight, bottom]);

    canvas.drawPath(topFace, Paint()..color = const Color(0xFFFFDE8A));
    canvas.drawPath(leftFace, Paint()..color = AppColors.gold);
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFFB9852A));

    canvas.drawLine(
      Offset.lerp(left, top, 0.5)!,
      Offset.lerp(c, right, 0.5)!,
      Paint()
        ..strokeWidth = s * 0.018
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF7A132F).withValues(alpha: 0.35),
    );

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.012
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF4E0A1E).withValues(alpha: 0.28);
    canvas.drawPath(topFace, edge);
    canvas.drawPath(leftFace, edge);
    canvas.drawPath(rightFace, edge);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
