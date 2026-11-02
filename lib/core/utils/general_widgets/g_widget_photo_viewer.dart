import 'dart:io';

import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

/// One photo for [GWidgetPhotoViewer]: a file on the device and a caption.
class GWidgetPhotoItem {
  final String path;
  final String? caption;
  const GWidgetPhotoItem({required this.path, this.caption});
}

/// Full-screen photos: swipe between them, pinch to zoom.
class GWidgetPhotoViewer extends StatefulWidget {
  const GWidgetPhotoViewer(
      {super.key, required this.photos, this.initialIndex = 0});
  final List<GWidgetPhotoItem> photos;
  final int initialIndex;

  static Future<void> open(BuildContext context, List<GWidgetPhotoItem> photos,
      {int initialIndex = 0}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              GWidgetPhotoViewer(photos: photos, initialIndex: initialIndex)),
    );
  }

  @override
  State<GWidgetPhotoViewer> createState() => _GWidgetPhotoViewerState();
}

class _GWidgetPhotoViewerState extends State<GWidgetPhotoViewer> {
  late final PageController _pages =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caption = widget.photos[_index].caption;
    final background = AppTheme.scaffoldBackground;
    final foreground = AppTheme.textPrimary;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        title: Text('{0} of {1}'.trArgs([_index + 1, widget.photos.length]),
            style: AppTheme.font(
                color: foreground,
                fontSize: AppTheme.textTitle,
                fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) => InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.file(
                    File(widget.photos[index].path),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: AppTheme.iconGrey, size: 48),
                        const SizedBox(height: 8),
                        Text('This photo is no longer on this device'.tr,
                            style: AppTheme.font(
                                color: foreground,
                                fontSize: AppTheme.textBody)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if ((caption ?? '').isNotEmpty)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(caption!,
                    textAlign: TextAlign.center,
                    style: AppTheme.font(
                        color: foreground.withValues(alpha: .85),
                        fontSize: AppTheme.textBody,
                        height: 1.4)),
              ),
            ),
        ],
      ),
    );
  }
}
