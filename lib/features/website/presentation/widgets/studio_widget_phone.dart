import 'package:flutter/material.dart';

import '../../../../app/visit_proof_app.dart';

/// The real app running inside a phone-shaped frame. The app is told the
/// frame is its screen, so its layout matches a phone.
class StudioWidgetPhone extends StatelessWidget {
  const StudioWidgetPhone({super.key});

  /// A slightly short phone screen: the frame fills the browser's height,
  /// so a shorter screen draws the app larger.
  static const Size screen = Size(380, 760);

  static const double _bezel = 8;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        width: screen.width + _bezel * 2,
        height: screen.height + _bezel * 2,
        padding: const EdgeInsets.all(_bezel),
        decoration: BoxDecoration(
          color: const Color(0xFF111318),
          borderRadius: BorderRadius.circular(46),
          boxShadow: const [
            BoxShadow(
                color: Color(0x26000000), blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        // Painted on its own layer, so the page around it can scroll or
        // change without repainting the app, and the other way round.
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: StudioWidgetAppScreen(size: screen),
          ),
        ),
      ),
    );
  }
}

/// The app sized to [size] as if that were the whole screen.
class StudioWidgetAppScreen extends StatelessWidget {
  const StudioWidgetAppScreen({super.key, required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SizedBox.fromSize(
      size: size,
      child: MediaQuery(
        data: media.copyWith(
          size: size,
          padding: EdgeInsets.zero,
          viewPadding: EdgeInsets.zero,
          viewInsets: EdgeInsets.zero,
        ),
        child: const VisitProofApp(),
      ),
    );
  }
}
