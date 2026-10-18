import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';

enum TechnicianStatus { available, busy, offline }

class TechnicianStatusSwitch {
  final TechnicianStatus? technicianStatusEnum;
  final int? technicianStatusID;

  TechnicianStatusSwitch({this.technicianStatusEnum, this.technicianStatusID});

  int switchID() {
    switch (technicianStatusEnum) {
      case null:
        return 3;
      case TechnicianStatus.available:
        return 1;
      case TechnicianStatus.busy:
        return 2;
      case TechnicianStatus.offline:
        return 3;
    }
  }

  TechnicianStatus switchEnum() {
    if (technicianStatusID == 1) {
      return TechnicianStatus.available;
    } else if (technicianStatusID == 2) {
      return TechnicianStatus.busy;
    } else if (technicianStatusID == 3) {
      return TechnicianStatus.offline;
    }
    return TechnicianStatus.offline;
  }

  Color getColor() {
    if (technicianStatusID == 1) {
      return AppColors.statGreen;
    } else if (technicianStatusID == 2) {
      return AppColors.pending;
    } else if (technicianStatusID == 3) {
      return AppColors.iconGrey;
    }

    switch (technicianStatusEnum) {
      case null:
        return AppColors.iconGrey;
      case TechnicianStatus.available:
        return AppColors.statGreen;
      case TechnicianStatus.busy:
        return AppColors.pending;
      case TechnicianStatus.offline:
        return AppColors.iconGrey;
    }
  }

  String getText() {
    if (technicianStatusID == 1) {
      return 'Available';
    } else if (technicianStatusID == 2) {
      return 'Busy';
    } else if (technicianStatusID == 3) {
      return 'Offline';
    }

    switch (technicianStatusEnum) {
      case null:
        return 'Offline';
      case TechnicianStatus.available:
        return 'Available';
      case TechnicianStatus.busy:
        return 'Busy';
      case TechnicianStatus.offline:
        return 'Offline';
    }
  }
}
