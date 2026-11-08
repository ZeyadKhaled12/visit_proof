import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';

enum PaymentStatus { unpaid, pending, partiallyPaid, paid, cancelled, refunded }

class PaymentStatusSwitch {
  final PaymentStatus? paymentStatusEnum;
  final int? paymentStatusID;

  PaymentStatusSwitch({this.paymentStatusEnum, this.paymentStatusID});

  int switchID() {
    switch (paymentStatusEnum) {
      case null:
        return 1;
      case PaymentStatus.unpaid:
        return 1;
      case PaymentStatus.pending:
        return 2;
      case PaymentStatus.partiallyPaid:
        return 3;
      case PaymentStatus.paid:
        return 4;
      case PaymentStatus.cancelled:
        return 5;
      case PaymentStatus.refunded:
        return 6;
    }
  }

  PaymentStatus switchEnum() {
    if (paymentStatusID == 1) {
      return PaymentStatus.unpaid;
    } else if (paymentStatusID == 2) {
      return PaymentStatus.pending;
    } else if (paymentStatusID == 3) {
      return PaymentStatus.partiallyPaid;
    } else if (paymentStatusID == 4) {
      return PaymentStatus.paid;
    } else if (paymentStatusID == 5) {
      return PaymentStatus.cancelled;
    } else if (paymentStatusID == 6) {
      return PaymentStatus.refunded;
    }
    return PaymentStatus.unpaid;
  }

  Color getColor() {
    if (paymentStatusID == 1) {
      return AppTheme.iconGrey;
    } else if (paymentStatusID == 2) {
      return AppTheme.pending;
    } else if (paymentStatusID == 3) {
      return AppTheme.primary;
    } else if (paymentStatusID == 4) {
      return AppTheme.statGreen;
    } else if (paymentStatusID == 5) {
      return AppTheme.statOrange;
    } else if (paymentStatusID == 6) {
      return AppTheme.secondary;
    }

    switch (paymentStatusEnum) {
      case null:
        return AppTheme.iconGrey;
      case PaymentStatus.unpaid:
        return AppTheme.iconGrey;
      case PaymentStatus.pending:
        return AppTheme.pending;
      case PaymentStatus.partiallyPaid:
        return AppTheme.primary;
      case PaymentStatus.paid:
        return AppTheme.statGreen;
      case PaymentStatus.cancelled:
        return AppTheme.statOrange;
      case PaymentStatus.refunded:
        return AppTheme.secondary;
    }
  }

  String getText() {
    if (paymentStatusID == 1) {
      return 'Unpaid'.tr;
    } else if (paymentStatusID == 2) {
      return 'Pending'.tr;
    } else if (paymentStatusID == 3) {
      return 'Partially Paid'.tr;
    } else if (paymentStatusID == 4) {
      return 'Paid'.tr;
    } else if (paymentStatusID == 5) {
      return 'Cancelled'.tr;
    } else if (paymentStatusID == 6) {
      return 'Refunded'.tr;
    }

    switch (paymentStatusEnum) {
      case null:
        return 'Unpaid'.tr;
      case PaymentStatus.unpaid:
        return 'Unpaid'.tr;
      case PaymentStatus.pending:
        return 'Pending'.tr;
      case PaymentStatus.partiallyPaid:
        return 'Partially Paid'.tr;
      case PaymentStatus.paid:
        return 'Paid'.tr;
      case PaymentStatus.cancelled:
        return 'Cancelled'.tr;
      case PaymentStatus.refunded:
        return 'Refunded'.tr;
    }
  }
}
