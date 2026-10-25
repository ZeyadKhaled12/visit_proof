import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';

enum Priority { emergency, high, normal, low }

class PrioritySwitch {
  final Priority? priorityEnum;
  final int? priorityID;

  PrioritySwitch({this.priorityEnum, this.priorityID});

  int switchID() {
    switch (priorityEnum) {
      case null:
        return 1;
      case Priority.emergency:
        return 2;
      case Priority.high:
        return 3;
      case Priority.normal:
        return 1;
      case Priority.low:
        return 4;
    }
  }

  Priority switchEnum() {
    if (priorityID == 1) {
      return Priority.normal;
    } else if (priorityID == 2) {
      return Priority.emergency;
    } else if (priorityID == 3) {
      return Priority.high;
    } else if (priorityID == 4) {
      return Priority.low;
    }
    return Priority.normal;
  }

  Color getColor() {
    if (priorityID == 1) {
      return AppColors.primary;
    } else if (priorityID == 2) {
      return AppColors.statOrange;
    } else if (priorityID == 3) {
      return AppColors.secondary;
    } else if (priorityID == 4) {
      return AppColors.cardColor;
    }

    switch (priorityEnum) {
      case null:
        return AppColors.primary;
      case Priority.emergency:
        return AppColors.statOrange;
      case Priority.high:
        return AppColors.secondary;
      case Priority.normal:
        return AppColors.primary;
      case Priority.low:
        return AppColors.cardColor;
    }
  }

  String getText() {
    if (priorityID == 1) {
      return 'normal';
    } else if (priorityID == 2) {
      return 'emergency';
    } else if (priorityID == 3) {
      return 'high';
    } else if (priorityID == 4) {
      return 'low';
    }

    switch (priorityEnum) {
      case null:
        return 'normal';
      case Priority.emergency:
        return 'emergency';
      case Priority.high:
        return 'high';
      case Priority.normal:
        return 'normal';
      case Priority.low:
        return 'low';
    }
  }
}
