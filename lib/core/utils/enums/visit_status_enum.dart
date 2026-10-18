import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';

enum VisitStatus { scheduled, enRoute, onSite, inProgress, signed }

class VisitStatusSwitch {
  final VisitStatus? visitStatusEnum;
  final int? visitStatusID;

  VisitStatusSwitch({this.visitStatusEnum, this.visitStatusID});

  int switchID() {
    switch (visitStatusEnum) {
      case null:
        return 1;
      case VisitStatus.scheduled:
        return 1;
      case VisitStatus.enRoute:
        return 2;
      case VisitStatus.onSite:
        return 3;
      case VisitStatus.inProgress:
        return 4;
      case VisitStatus.signed:
        return 5;
    }
  }

  VisitStatus switchEnum() {
    if (visitStatusID == 1) {
      return VisitStatus.scheduled;
    } else if (visitStatusID == 2) {
      return VisitStatus.enRoute;
    } else if (visitStatusID == 3) {
      return VisitStatus.onSite;
    } else if (visitStatusID == 4) {
      return VisitStatus.inProgress;
    } else if (visitStatusID == 5) {
      return VisitStatus.signed;
    }
    return VisitStatus.scheduled;
  }

  Color getColor() {
    if (visitStatusID == 1) {
      return AppColors.iconGrey;
    } else if (visitStatusID == 2) {
      return AppColors.pending;
    } else if (visitStatusID == 3) {
      return AppColors.secondary;
    } else if (visitStatusID == 4) {
      return AppColors.primary;
    } else if (visitStatusID == 5) {
      return AppColors.statGreen;
    }

    switch (visitStatusEnum) {
      case null:
        return AppColors.iconGrey;
      case VisitStatus.scheduled:
        return AppColors.iconGrey;
      case VisitStatus.enRoute:
        return AppColors.pending;
      case VisitStatus.onSite:
        return AppColors.secondary;
      case VisitStatus.inProgress:
        return AppColors.primary;
      case VisitStatus.signed:
        return AppColors.statGreen;
    }
  }

  String getText() {
    if (visitStatusID == 1) {
      return 'Scheduled';
    } else if (visitStatusID == 2) {
      return 'En Route';
    } else if (visitStatusID == 3) {
      return 'On Site';
    } else if (visitStatusID == 4) {
      return 'In Progress';
    } else if (visitStatusID == 5) {
      return 'Completed & Signed';
    }

    switch (visitStatusEnum) {
      case null:
        return 'Scheduled';
      case VisitStatus.scheduled:
        return 'Scheduled';
      case VisitStatus.enRoute:
        return 'En Route';
      case VisitStatus.onSite:
        return 'On Site';
      case VisitStatus.inProgress:
        return 'In Progress';
      case VisitStatus.signed:
        return 'Completed & Signed';
    }
  }
}
