import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';

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
      return AppColors.textLightHint;
    } else if (paymentStatusID == 2) {
      return AppColors.pending;
    } else if (paymentStatusID == 3) {
      return AppColors.cardAccent;
    } else if (paymentStatusID == 4) {
      return AppColors.statGreen;
    } else if (paymentStatusID == 5) {
      return AppColors.statOrange;
    } else if (paymentStatusID == 6) {
      return AppColors.secondary;
    }

    switch (paymentStatusEnum) {
      case null:
        return AppColors.textLightHint;
      case PaymentStatus.unpaid:
        return AppColors.textLightHint;
      case PaymentStatus.pending:
        return AppColors.pending;
      case PaymentStatus.partiallyPaid:
        return AppColors.cardAccent;
      case PaymentStatus.paid:
        return AppColors.statGreen;
      case PaymentStatus.cancelled:
        return AppColors.statOrange;
      case PaymentStatus.refunded:
        return AppColors.secondary;
    }
  }

  String getText() {
    if (paymentStatusID == 1) {
      return 'Unpaid';
    } else if (paymentStatusID == 2) {
      return 'Pending';
    } else if (paymentStatusID == 3) {
      return 'Partially Paid';
    } else if (paymentStatusID == 4) {
      return 'Paid';
    } else if (paymentStatusID == 5) {
      return 'Cancelled';
    } else if (paymentStatusID == 6) {
      return 'Refunded';
    }

    switch (paymentStatusEnum) {
      case null:
        return 'Unpaid';
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.partiallyPaid:
        return 'Partially Paid';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}
