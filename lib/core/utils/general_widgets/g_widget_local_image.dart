import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A photo saved by the app. On a phone it is a file; in the browser demo
/// it is a temporary link the camera picker created, valid until the page
/// is closed.
class GWidgetLocalImage extends StatelessWidget {
  const GWidgetLocalImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit,
    this.cacheWidth,
    this.errorBuilder,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? cacheWidth;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(path,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: cacheWidth,
          errorBuilder: errorBuilder);
    }
    return Image.file(File(path),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: errorBuilder);
  }
}
