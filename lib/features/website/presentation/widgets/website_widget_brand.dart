import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The platform's identity: Wizpo sells small business apps; Visit Proof is
/// one of them. The originals of the logo live in `web/brand/`.
class WebsiteBrand {
  WebsiteBrand._();

  static const String name = 'Wizpo';
  static const String tagline = 'Small apps. Big magic.';

  /// The browser tab title (same as `<title>` in `web/index.html`).
  static const String pageTitle =
      'Visit Proof | تطبيق إدارة الفنيين والصيانة وإثبات الزيارات';

  /// The wordmark is always Inter, also on the Arabic site.
  static TextStyle wordmark({required double fontSize, required Color color}) =>
      GoogleFonts.getFont('Inter',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: -fontSize * .045,
          height: 1);
}

/// The Wizpo icon (the W with the gold star), drawn from
/// `web/brand/wizpo-icon.svg` so it stays sharp at every size.
class WizpoMark extends StatelessWidget {
  const WizpoMark({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: const _WizpoPainter());
  }
}

class _WizpoPainter extends CustomPainter {
  const _WizpoPainter();

  static const _cream = Color(0xFFF4EAD6);

  @override
  void paint(Canvas canvas, Size size) {
    // The SVG's coordinates are 0–256.
    canvas.scale(size.width / 256);

    const box = Rect.fromLTWH(0, 0, 256, 256);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(59)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, .48, 1],
          colors: [Color(0xFF654575), Color(0xFF4B315F), Color(0xFF15182D)],
        ).createShader(box),
    );

    // The shine arc.
    canvas.drawPath(
      Path()
        ..moveTo(28, 59)
        ..cubicTo(70, 19, 174, -1, 224, 35),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..color = _cream.withValues(alpha: .18),
    );

    // The W.
    canvas.drawPath(
      Path()
        ..moveTo(52, 83)
        ..lineTo(89, 187)
        ..lineTo(129, 109)
        ..lineTo(170, 187)
        ..lineTo(208, 89),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 19.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = _cream,
    );

    // The star.
    const starBox = Rect.fromLTRB(178, 37, 251, 119);
    canvas.drawPath(
      Path()
        ..moveTo(215, 37)
        ..cubicTo(217, 63, 227, 75, 251, 78)
        ..cubicTo(228, 81, 218, 94, 215, 119)
        ..cubicTo(213, 94, 203, 81, 178, 78)
        ..cubicTo(204, 76, 212, 63, 215, 37)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, .55, 1],
          colors: [_cream, Color(0xFFE8C982), Color(0xFFD6AC58)],
        ).createShader(starBox),
    );

    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(217, 140, 16, 16),
            const Radius.circular(4)),
        Paint()..color = const Color(0xFFD6AC58));
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(237, 162, 9, 9),
            const Radius.circular(2.5)),
        Paint()..color = const Color(0xFF1E5045));
    canvas.drawCircle(
        const Offset(185, 40), 3.6, Paint()..color = _cream.withValues(alpha: .85));
  }

  @override
  bool shouldRepaint(covariant _WizpoPainter oldDelegate) => false;
}
