import 'dart:convert';

import 'package:intl/intl.dart';

/// The QR code on a Saudi tax invoice: seller, VAT number, time, total and
/// VAT as tag-length-value fields, in Base64.
class GFunVatQr {
  GFunVatQr._();

  static String encode({
    required String seller,
    required String vatNumber,
    required DateTime issuedAt,
    required num total,
    required num vat,
  }) {
    final time =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(issuedAt.toUtc());
    final fields = [
      seller,
      vatNumber,
      time,
      total.toStringAsFixed(2),
      vat.toStringAsFixed(2),
    ];

    final bytes = <int>[];
    for (var i = 0; i < fields.length; i++) {
      final value = utf8.encode(fields[i]);
      bytes
        ..add(i + 1)
        ..add(value.length)
        ..addAll(value);
    }
    return base64.encode(bytes);
  }
}
