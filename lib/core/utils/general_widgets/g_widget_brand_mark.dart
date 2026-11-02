import 'package:flutter/material.dart';

import '../../../configs/app_brand.dart';

/// The app's icon: the customer's uploaded logo, or the icon picked in the
/// design studio.
class GWidgetBrandMark extends StatelessWidget {
  const GWidgetBrandMark({super.key, required this.size, required this.color});

  final double size;

  /// Icon color; a logo keeps its own colors.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final logo = AppBrand.value.logo;
    if (logo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * .22),
        child: Image.memory(logo, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Icon(AppBrand.icon.icon, color: color, size: size);
  }
}
