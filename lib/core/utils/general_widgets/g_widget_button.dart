import 'package:flutter/material.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import 'g_widget_loading.dart';

class GWidgetButton extends StatelessWidget {
  const GWidgetButton(
      {super.key,
      this.backgroundColor,
      this.colorText = Colors.white,
      this.fontSize = 18,
      this.text,
      required this.onPressed,
      this.width,
      this.height,
      this.isEnable = true,
      this.isLoading = false,
      this.paddingLeftRight = 10,
      this.paddingTopBottom = 10,
      this.raduis = 15,
      this.border,
      this.widget,
      this.noEnablebackgroundColor,
      this.loadingColor,
      this.boxShadow,
      this.fontWeight,
      this.loadingSize,
      this.gradient,
      this.loadingStrokeWidth});
  final Color? backgroundColor;
  final Color? noEnablebackgroundColor;
  final Color colorText;
  final double fontSize;
  final String? text;
  final Widget? widget;
  final Function() onPressed;
  final double? width;
  final double? height;
  final bool isEnable;
  final bool isLoading;
  final Color? loadingColor;
  final double raduis;
  final double paddingLeftRight;
  final double paddingTopBottom;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double? loadingSize;
  final FontWeight? fontWeight;
  final Gradient? gradient;
  final double? loadingStrokeWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !isLoading && isEnable ? onPressed : null,
        highlightColor: AppColors.secondary,
        splashColor: AppColors.secondary,
        child: Container(
            width: width,
            height: height,
            padding: EdgeInsets.symmetric(
                horizontal: paddingLeftRight, vertical: paddingTopBottom),
            decoration: BoxDecoration(
                border: border,
                boxShadow: boxShadow,
                gradient: gradient,
                color: isEnable
                    ? backgroundColor ?? AppColors.primary
                    : noEnablebackgroundColor ??
                        Colors.grey.withValues(alpha: .8),
                borderRadius: BorderRadius.circular(raduis)),
            child: isLoading
                ? Center(
                    child: GWidgetLoadingCircle(
                        color: loadingColor ?? Colors.white,
                        width: loadingSize,
                        strokeWidth: loadingStrokeWidth ?? 5,
                        height: loadingSize),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (text != null)
                        Text(text ?? '',
                            textAlign: TextAlign.center,
                            style: AppFonts(
                                color: isEnable ? colorText : Colors.white70,
                                fontSize: fontSize,
                                fontWeight: fontWeight ?? FontWeight.w600)),
                      if (widget != null) widget!
                    ],
                  )),
      ),
    );
  }
}
