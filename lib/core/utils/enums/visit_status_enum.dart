import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';

enum VisitStatus {
  draft,
  scheduled,
  assigned,
  onWay,
  inProgress,
  completed,
  cancel
}

class VisitStatusSwitch {
  final VisitStatus? visitStatusEnum;
  final int? visitStatusID;

  VisitStatusSwitch({this.visitStatusEnum, this.visitStatusID});

  int switchID() {
    switch (visitStatusEnum) {
      case null:
        return 1;
      case VisitStatus.draft:
        return 1;
      case VisitStatus.scheduled:
        return 2;
      case VisitStatus.assigned:
        return 3;
      case VisitStatus.onWay:
        return 4;
      case VisitStatus.inProgress:
        return 5;
      case VisitStatus.completed:
        return 6;
      case VisitStatus.cancel:
        return 7;
    }
  }

  VisitStatus switchEnum() {
    if (visitStatusID == 1) {
      return VisitStatus.draft;
    } else if (visitStatusID == 2) {
      return VisitStatus.scheduled;
    } else if (visitStatusID == 3) {
      return VisitStatus.assigned;
    } else if (visitStatusID == 4) {
      return VisitStatus.onWay;
    } else if (visitStatusID == 5) {
      return VisitStatus.inProgress;
    } else if (visitStatusID == 6) {
      return VisitStatus.completed;
    } else if (visitStatusID == 7) {
      return VisitStatus.cancel;
    }
    return VisitStatus.draft;
  }

  Color getColor() {
    if (visitStatusID == 1) {
      return AppColors.iconGrey;
    } else if (visitStatusID == 2) {
      return AppColors.pending;
    } else if (visitStatusID == 3) {
      return AppColors.primary;
    } else if (visitStatusID == 4) {
      return AppColors.secondary;
    } else if (visitStatusID == 5) {
      return AppColors.pending;
    } else if (visitStatusID == 6) {
      return AppColors.statGreen;
    } else if (visitStatusID == 7) {
      return AppColors.statOrange;
    }

    switch (visitStatusEnum) {
      case null:
        return AppColors.iconGrey;
      case VisitStatus.draft:
        return AppColors.iconGrey;
      case VisitStatus.scheduled:
        return AppColors.pending;
      case VisitStatus.assigned:
        return AppColors.primary;
      case VisitStatus.onWay:
        return AppColors.secondary;
      case VisitStatus.inProgress:
        return AppColors.pending;
      case VisitStatus.completed:
        return AppColors.statGreen;
      case VisitStatus.cancel:
        return AppColors.statOrange;
    }
  }

  String getText() {
    if (visitStatusID == 1) {
      return 'draft';
    } else if (visitStatusID == 2) {
      return 'scheduled';
    } else if (visitStatusID == 3) {
      return 'assigned';
    } else if (visitStatusID == 4) {
      return 'on way';
    } else if (visitStatusID == 5) {
      return 'in progress';
    } else if (visitStatusID == 6) {
      return 'completed';
    } else if (visitStatusID == 7) {
      return 'cancel';
    }

    switch (visitStatusEnum) {
      case null:
        return 'draft';
      case VisitStatus.draft:
        return 'draft';
      case VisitStatus.scheduled:
        return 'scheduled';
      case VisitStatus.assigned:
        return 'assigned';
      case VisitStatus.onWay:
        return 'on way';
      case VisitStatus.inProgress:
        return 'in progress';
      case VisitStatus.completed:
        return 'completed';
      case VisitStatus.cancel:
        return 'cancel';
    }
  }
}
