import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';

/// When a visit photo was taken: before the work, after it, with a note,
/// or as the receipt for money collected on site.
enum PhotoKind { before, after, note, receipt }

class PhotoKindSwitch {
  final PhotoKind? photoKindEnum;
  final int? photoKindID;

  PhotoKindSwitch({this.photoKindEnum, this.photoKindID});

  int switchID() {
    switch (photoKindEnum) {
      case null:
      case PhotoKind.note:
        return 3;
      case PhotoKind.before:
        return 1;
      case PhotoKind.after:
        return 2;
      case PhotoKind.receipt:
        return 4;
    }
  }

  PhotoKind switchEnum() {
    if (photoKindID == 1) return PhotoKind.before;
    if (photoKindID == 2) return PhotoKind.after;
    if (photoKindID == 4) return PhotoKind.receipt;
    return PhotoKind.note;
  }

  Color getColor() {
    switch (photoKindEnum ?? switchEnum()) {
      case PhotoKind.before:
        return AppTheme.pending;
      case PhotoKind.after:
        return AppTheme.statGreen;
      case PhotoKind.note:
        return AppTheme.secondary;
      case PhotoKind.receipt:
        return AppTheme.primary;
    }
  }

  String getText() {
    switch (photoKindEnum ?? switchEnum()) {
      case PhotoKind.before:
        return 'Before work'.tr;
      case PhotoKind.after:
        return 'After work'.tr;
      case PhotoKind.note:
        return 'With a note'.tr;
      case PhotoKind.receipt:
        return 'Payment receipt'.tr;
    }
  }
}
