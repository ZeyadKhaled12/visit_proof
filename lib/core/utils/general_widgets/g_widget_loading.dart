import 'package:flutter/material.dart';
import '../../../../configs/app_theme.dart';

class GWidgetLoading extends StatelessWidget {
  const GWidgetLoading(
      {super.key,
      required this.isLoading,
      required this.body,
      this.strockColor,
      this.opacity = 0.4});
  final bool isLoading;
  final Color? strockColor;
  final double opacity;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Opacity(opacity: isLoading ? opacity : 1, child: body),
        if (isLoading)
          Center(
            child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(strockColor ?? AppTheme.primary)),
          )
      ],
    );
  }
}

class GWidgetLoadingCircle extends StatelessWidget {
  const GWidgetLoadingCircle(
      {super.key,
      this.color,
      this.strokeWidth = 5,
      this.height,
      this.width});
  final Color? color;
  final double strokeWidth;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? AppTheme.primary)),
    );
  }
}
