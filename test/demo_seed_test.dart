import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/configs/app_brand.dart';
import 'package:visit_proof/configs/app_theme.dart';
import 'package:visit_proof/core/demo/demo_seed.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/session/app_session.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums/app_role_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/features/clients/data/datasource/clients_remote_data_source.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_payment_history_model.dart';
import 'package:visit_proof/features/visits/data/datasource/visits_remote_data_source.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalPref.sharedPreferences = await SharedPreferences.getInstance();
    await DemoSeed.run();
    AppSession.current.value = null;
  });

  test('the test company has many visits in every status', () async {
    final visits =
        await VisitsRemoteDataSource().getVisits(const NoParameters());

    expect(visits.length, greaterThan(150));
    expect(visits.map((e) => e.status).toSet(), containsAll(VisitStatus.values));
    expect(visits.map((e) => e.id).toSet(), hasLength(visits.length));
    expect(visits.every((e) => (e.invoiceID ?? '').isNotEmpty), isTrue);
  });

  test('the demo technician sees only his own visits, one in each step today',
      () async {
    AppSession.current.value = const AppSessionModel(
        role: AppRole.technician,
        technicianId: 'demo-tech-1',
        technicianName: 'Ahmed Saleh',
        technicianEmail: DemoSeed.technicianEmail);

    final visits =
        await VisitsRemoteDataSource().getVisits(const NoParameters());

    expect(visits.every((e) => e.technicianModel?.id == 'demo-tech-1'), isTrue);
    expect(
        visits.map((e) => e.status),
        containsAll([
          VisitStatus.assigned,
          VisitStatus.onWay,
          VisitStatus.inProgress,
          VisitStatus.completed
        ]));
  });

  test('every invoice matches its payment ledger', () {
    final prefs = LocalPref.sharedPreferences;
    final invoices = prefs
        .getStringList('invoices')!
        .map((e) => InvoiceDetailModel.fromJson(jsonDecode(e)))
        .toList();
    final payments = prefs
        .getStringList('invoice_payments')!
        .map((e) => InvoicePaymentHistoryModel.fromJson(jsonDecode(e)))
        .toList();

    int cents(num? value) => ((value ?? 0) * 100).round();
    for (final invoice in invoices) {
      final ledger = payments.where((e) => e.invoiceId == invoice.id);
      final paid = ledger
          .where((e) => e.countsAsPaid)
          .fold<int>(0, (sum, e) => sum + cents(e.paymentAmount));
      final pending = ledger
          .where((e) => e.isPending)
          .fold<int>(0, (sum, e) => sum + cents(e.paymentAmount));

      expect(paid, cents(invoice.paidAmount), reason: invoice.invoiceNumber);
      expect(pending, cents(invoice.pendingAmount),
          reason: invoice.invoiceNumber);
      expect(cents(invoice.remainingAmount),
          cents(invoice.totalAmount) - cents(invoice.paidAmount),
          reason: invoice.invoiceNumber);
    }
  });

  test('test clients can be read back', () async {
    final clients =
        await ClientsRemoteDataSource().getClients(const NoParameters());
    expect(clients, hasLength(24));
  });

  test('brand colors, fonts and text size replace the defaults', () {
    AppBrand.update(const AppBrandModel(
      colors: {
        AppBrandColor.primary: Color(0xFF0B63CE),
        AppBrandColor.background: Color(0xFFFFF8E1),
      },
      fontArabic: 'Tajawal',
      fontScale: 1.2,
    ));
    expect(AppTheme.palette.primary, const Color(0xFF0B63CE));
    expect(AppTheme.palette.scaffoldBackground, const Color(0xFFFFF8E1));
    expect(AppBrand.hex(AppTheme.palette.primary), '#0B63CE');
    expect(AppTheme.activeFontScale, closeTo(1.2, .001));

    AppBrand.reset();
    expect(AppTheme.palette.primary, AppTheme.light.primary);
    expect(AppTheme.activeFontScale, 1.0);
  });
}
