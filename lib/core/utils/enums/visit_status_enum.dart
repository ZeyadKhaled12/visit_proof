import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';

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
      return AppTheme.iconGrey;
    } else if (visitStatusID == 2) {
      return AppTheme.pending;
    } else if (visitStatusID == 3) {
      return AppTheme.primary;
    } else if (visitStatusID == 4) {
      return AppTheme.secondary;
    } else if (visitStatusID == 5) {
      return AppTheme.pending;
    } else if (visitStatusID == 6) {
      return AppTheme.statGreen;
    } else if (visitStatusID == 7) {
      return AppTheme.statOrange;
    }

    switch (visitStatusEnum) {
      case null:
        return AppTheme.iconGrey;
      case VisitStatus.draft:
        return AppTheme.iconGrey;
      case VisitStatus.scheduled:
        return AppTheme.pending;
      case VisitStatus.assigned:
        return AppTheme.primary;
      case VisitStatus.onWay:
        return AppTheme.secondary;
      case VisitStatus.inProgress:
        return AppTheme.pending;
      case VisitStatus.completed:
        return AppTheme.statGreen;
      case VisitStatus.cancel:
        return AppTheme.statOrange;
    }
  }

  String getText() {
    if (visitStatusID == 1) {
      return 'Draft';
    } else if (visitStatusID == 2) {
      return 'Scheduled';
    } else if (visitStatusID == 3) {
      return 'Assigned';
    } else if (visitStatusID == 4) {
      return 'On The Way';
    } else if (visitStatusID == 5) {
      return 'In Progress';
    } else if (visitStatusID == 6) {
      return 'Completed';
    } else if (visitStatusID == 7) {
      return 'Cancelled';
    }

    switch (visitStatusEnum) {
      case null:
        return 'Draft';
      case VisitStatus.draft:
        return 'Draft';
      case VisitStatus.scheduled:
        return 'Scheduled';
      case VisitStatus.assigned:
        return 'Assigned';
      case VisitStatus.onWay:
        return 'On The Way';
      case VisitStatus.inProgress:
        return 'In Progress';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.cancel:
        return 'Cancelled';
    }
  }
}
