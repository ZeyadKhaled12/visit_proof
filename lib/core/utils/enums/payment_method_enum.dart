import 'package:visit_proof/configs/app_language.dart';
enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  mobileWallet,
  other,
}

class PaymentMethodSwitch {
  final PaymentMethod? paymentMethodEnum;
  final int? paymentMethodID;

  PaymentMethodSwitch({
    this.paymentMethodEnum,
    this.paymentMethodID,
  });

  int switchID() {
    switch (paymentMethodEnum) {
      case PaymentMethod.cash:
        return 1;
      case PaymentMethod.card:
        return 2;
      case PaymentMethod.bankTransfer:
        return 3;
      case PaymentMethod.mobileWallet:
        return 4;
      case PaymentMethod.other:
      case null:
        return 5;
    }
  }

  PaymentMethod switchEnum() {
    switch (paymentMethodID) {
      case 1:
        return PaymentMethod.cash;
      case 2:
        return PaymentMethod.card;
      case 3:
        return PaymentMethod.bankTransfer;
      case 4:
        return PaymentMethod.mobileWallet;
      default:
        return PaymentMethod.other;
    }
  }

  String getText() {
    final method = paymentMethodEnum ?? switchEnum();

    switch (method) {
      case PaymentMethod.cash:
        return 'Cash'.tr;
      case PaymentMethod.card:
        return 'Card'.tr;
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer'.tr;
      case PaymentMethod.mobileWallet:
        return 'Mobile Wallet'.tr;
      case PaymentMethod.other:
        return 'Other'.tr;
    }
  }
}
