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
      return AppTheme.textLightHint;
    } else if (paymentStatusID == 2) {
      return AppTheme.pending;
    } else if (paymentStatusID == 3) {
      return AppTheme.cardAccent;
    } else if (paymentStatusID == 4) {
      return AppTheme.statGreen;
    } else if (paymentStatusID == 5) {
      return AppTheme.statOrange;
    } else if (paymentStatusID == 6) {
      return AppTheme.secondary;
    }

    switch (paymentStatusEnum) {
      case null:
        return AppTheme.textLightHint;
      case PaymentStatus.unpaid:
        return AppTheme.textLightHint;
      case PaymentStatus.pending:
        return AppTheme.pending;
      case PaymentStatus.partiallyPaid:
        return AppTheme.cardAccent;
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
        return 'Paid';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}
