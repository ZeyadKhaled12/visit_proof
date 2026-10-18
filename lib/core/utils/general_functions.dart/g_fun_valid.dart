import 'package:intl_phone_field/phone_number.dart';

class GFunValid {
  static bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidPhoneNumber(PhoneNumber? phoneNumber) {
    if (phoneNumber == null || phoneNumber.number.trim().isEmpty) {
      return false;
    }

    try {
      return phoneNumber.isValidNumber();
    } catch (e) {
      return false;
    }
  }

  static bool isStrongPassword(String password) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    return regex.hasMatch(password);
  }
}
