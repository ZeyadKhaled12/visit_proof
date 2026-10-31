import 'package:flutter/material.dart';

class App {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String lang = 'en';
  static String currency = 'SAR';

  /// Days a customer has to pay once an invoice is issued.
  static int invoicePaymentTermDays = 14;
}
