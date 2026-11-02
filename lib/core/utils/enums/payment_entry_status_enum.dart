import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';

/// One payment entry in an invoice ledger. Money a technician collects in
/// the field stays [pending] until the admin confirms or rejects it.
/// Entries saved before this existed have no status and count as confirmed.
enum PaymentEntryStatus { confirmed, pending, rejected }

class PaymentEntryStatusSwitch {
  final PaymentEntryStatus? paymentEntryStatusEnum;
  final int? paymentEntryStatusID;

  PaymentEntryStatusSwitch(
      {this.paymentEntryStatusEnum, this.paymentEntryStatusID});

  int switchID() {
    switch (paymentEntryStatusEnum) {
      case null:
      case PaymentEntryStatus.confirmed:
        return 1;
      case PaymentEntryStatus.pending:
        return 2;
      case PaymentEntryStatus.rejected:
        return 3;
    }
  }

  PaymentEntryStatus switchEnum() {
    if (paymentEntryStatusID == 2) return PaymentEntryStatus.pending;
    if (paymentEntryStatusID == 3) return PaymentEntryStatus.rejected;
    return PaymentEntryStatus.confirmed;
  }

  Color getColor() {
    switch (paymentEntryStatusEnum ?? switchEnum()) {
      case PaymentEntryStatus.confirmed:
        return AppTheme.statGreen;
      case PaymentEntryStatus.pending:
        return AppTheme.pending;
      case PaymentEntryStatus.rejected:
        return AppTheme.statOrange;
    }
  }

  String getText() {
    switch (paymentEntryStatusEnum ?? switchEnum()) {
      case PaymentEntryStatus.confirmed:
        return 'Confirmed'.tr;
      case PaymentEntryStatus.pending:
        return 'Awaiting confirmation'.tr;
      case PaymentEntryStatus.rejected:
        return 'Rejected'.tr;
    }
  }
}
