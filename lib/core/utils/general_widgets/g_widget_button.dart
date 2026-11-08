import 'package:flutter/material.dart';
import '../../../configs/app_theme.dart';
import 'g_widget_loading.dart';

class GWidgetButton extends StatelessWidget {
  const GWidgetButton(
      {super.key,
      this.backgroundColor,
      this.colorText,
      this.fontSize = 18,
      this.text,
      required this.onPressed,
      this.width,
      this.height,
      this.isEnable = true,
      this.isLoading = false,
      this.paddingLeftRight = 10,
      this.paddingTopBottom = 10,
      this.raduis = 14,
      this.border,
      this.widget,
      this.noEnablebackgroundColor,
      this.loadingColor,
      this.fontWeight,
      this.loadingSize,
      this.loadingStrokeWidth});
  final Color? backgroundColor;
  final Color? noEnablebackgroundColor;
  /// Label color; defaults to the text color used on brand colors.
  final Color? colorText;
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
  final double? loadingSize;
  final FontWeight? fontWeight;
  final double? loadingStrokeWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !isLoading && isEnable ? onPressed : null,
        borderRadius: BorderRadius.circular(raduis),
        highlightColor: AppTheme.onPrimary.withValues(alpha: .08),
        splashColor: AppTheme.onPrimary.withValues(alpha: .12),
        child: Container(
            width: width,
            height: height,
            padding: EdgeInsets.symmetric(
                horizontal: paddingLeftRight, vertical: paddingTopBottom),
            decoration: BoxDecoration(
                border: border,
                color: isEnable
                    ? backgroundColor ?? AppTheme.primary
                    : noEnablebackgroundColor ?? AppTheme.locationChipBg,
                borderRadius: BorderRadius.circular(raduis)),
            child: isLoading
                ? Center(
                    child: GWidgetLoadingCircle(
                        color: loadingColor ?? AppTheme.onPrimary,
                        width: loadingSize,
                        strokeWidth: loadingStrokeWidth ?? 5,
                        height: loadingSize),
                  )
                // A long label shrinks instead of overflowing. Align and
                // FittedBox also work where the button has no width limit,
                // such as in an app bar.
                : Align(
                    heightFactor: 1,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (text != null)
                            Text(text ?? '',
                                textAlign: TextAlign.center,
                                style: AppTheme.font(
                                    color: isEnable
                                        ? colorText ?? AppTheme.onPrimary
                                        : AppTheme.textDarkHint,
                                    fontSize: fontSize,
                                    fontWeight: fontWeight ?? FontWeight.w700)),
                          if (widget != null) widget!
                        ],
                      ),
                    ),
                  )),
      ),
    );
  }
}
