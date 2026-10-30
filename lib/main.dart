import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/app/app.dart';
import 'core/local/local_pref.dart';
import 'core/services/services_locator.dart';
import 'core/utils/enums/payment_status_enum.dart';
import 'core/utils/general_models/g_model_catg.dart';
import 'core/utils/general_models/g_model_site.dart';
import 'features/clients/presentation/screens/add_client_scr.dart';
import 'features/clients/presentation/screens/client_detail_scr.dart';
import 'features/clients/presentation/screens/clients_scr.dart';
import 'features/invoices/data/models/invoice_detail_model.dart';
import 'features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'features/technicians/presentation/screens/add_tech_scr.dart';
import 'features/technicians/presentation/screens/technician_detail_scr.dart';
import 'features/add_visit/presentation/screens/add_visit_scr.dart';
import 'features/visits/data/models/visit_detail_models/visit_client_model.dart';

/*
1- add option to move to full screen of picks
2- add option to add more than one location in client detail
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServicesLocator().init();
  LocalPref.sharedPreferences = await SharedPreferences.getInstance();
  // LocalPref.sharedPreferences.clear();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFF2F2F2),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Visit Proof',
        navigatorKey: App.navigatorKey,
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => InvoiceDetailScreen(invoice: dummyInvoices[4]),
          ClientDetailScr.route: (context) => ClientDetailScr(),
          ClientsScr.route: (context) => ClientsScr(),
          AddClientScr.route: (context) => AddClientScr(),
          AddTechScr.route: (context) => AddTechScr(),
          TechnicianDetailScr.route: (context) => TechnicianDetailScr(),
          AddVisitScr.route: (context) => AddVisitScr(),
        });
  }
}

final _now = DateTime.now();

const _client = VisitClientModel(
  id: 'client-001',
  name: 'Ahmed Mohamed',
  phone: '+201001234567',
  email: 'ahmed@example.com',
  isWhatsAppPhone: true,
);

final _site = GModelSite(
  city: const GModelCatg(
    id: 'cairo',
    name: 'Cairo',
  ),
  addressDetail: 'Nasr City, Cairo, Egypt',
  latitude: 30.0600,
  longitude: 31.3300,
);

final List<InvoiceDetailModel> dummyInvoices = [
  // 1. DRAFT - Not issued yet
  // Actions: Edit Draft, Issue Invoice
  InvoiceDetailModel(
    id: 'inv-001',
    invoiceNumber: 'INV-2026-001',
    visitId: 'visit-001',
    visitNumber: 'VIS-2026-001',
    client: _client,
    site: _site,
    paymentStatus: PaymentStatus.unpaid,
    createdAt: _now.subtract(const Duration(days: 1)),
    issueDate: null,
    dueDate: _now.add(const Duration(days: 14)),
    subtotal: 1000,
    discountAmount: 100,
    taxAmount: 100,
    totalAmount: 1000,
    paidAmount: 0,
    remainingAmount: 1000,
    currency: 'EGP',
    notes: 'Draft invoice for AC maintenance.',
  ),

  // 2. ISSUED - UNPAID
  // Action: Record Payment
  InvoiceDetailModel(
    id: 'inv-002',
    invoiceNumber: 'INV-2026-002',
    visitId: 'visit-002',
    visitNumber: 'VIS-2026-002',
    client: _client,
    site: _site,
    paymentStatus: PaymentStatus.unpaid,
    createdAt: _now.subtract(const Duration(days: 3)),
    issueDate: _now.subtract(const Duration(days: 2)),
    dueDate: _now.add(const Duration(days: 7)),
    subtotal: 2500,
    discountAmount: 200,
    taxAmount: 300,
    totalAmount: 2600,
    paidAmount: 0,
    remainingAmount: 2600,
    currency: 'EGP',
    notes: 'Electrical maintenance invoice.',
  ),

  // 3. PAYMENT PENDING
  // Action: No direct payment action in current UI
  InvoiceDetailModel(
    id: 'inv-003',
    invoiceNumber: 'INV-2026-003',
    visitId: 'visit-003',
    visitNumber: 'VIS-2026-003',
    client: _client,
    site: _site,
    paymentStatus: PaymentStatus.pending,
    createdAt: _now.subtract(const Duration(days: 4)),
    issueDate: _now.subtract(const Duration(days: 3)),
    dueDate: _now.add(const Duration(days: 10)),
    subtotal: 1800,
    discountAmount: 0,
    taxAmount: 200,
    totalAmount: 2000,
    paidAmount: 0,
    remainingAmount: 2000,
    currency: 'EGP',
    notes: 'Bank transfer awaiting confirmation.',
  ),

  // 4. PARTIALLY PAID
  // Actions: Record Payment, Refund
  InvoiceDetailModel(
    id: 'inv-004',
    invoiceNumber: 'INV-2026-004',
    visitId: 'visit-004',
    visitNumber: 'VIS-2026-004',
    client: _client,
    site: _site,
    paymentStatus: PaymentStatus.partiallyPaid,
    createdAt: _now.subtract(const Duration(days: 5)),
    issueDate: _now.subtract(const Duration(days: 4)),
    dueDate: _now.add(const Duration(days: 12)),
    subtotal: 3000,
    discountAmount: 300,
    taxAmount: 300,
    totalAmount: 3000,
    paidAmount: 1200,
    remainingAmount: 1800,
    currency: 'EGP',
    notes: 'Partial cash payment received.',
  ),

  // 5. FULLY PAID
  // Action: Refund
  InvoiceDetailModel(
    id: 'inv-005',
    invoiceNumber: 'INV-2026-005',
    visitId: 'visit-005',
    visitNumber: 'VIS-2026-005',
    client: _client,
    site: _site,
    paymentStatus: PaymentStatus.paid,
    createdAt: _now.subtract(const Duration(days: 8)),
    issueDate: _now.subtract(const Duration(days: 7)),
    dueDate: _now.add(const Duration(days: 2)),
    subtotal: 1500,
    discountAmount: 100,
    taxAmount: 100,
    totalAmount: 1500,
    paidAmount: 1500,
    remainingAmount: 0,
    currency: 'EGP',
    notes: 'Invoice fully settled.',
  ),

  // 6. OVERDUE - PARTIALLY PAID
  // Actions: Record Payment, Refund
  // Also tests overdue warning
  InvoiceDetailModel(
    id: 'inv-006',
    invoiceNumber: 'INV-2026-006',
    visitId: 'visit-006',
    visitNumber: 'VIS-2026-006',
    client: _client,
    site: _site,
    paymentStatus: PaymentStatus.partiallyPaid,
    createdAt: _now.subtract(const Duration(days: 30)),
    issueDate: _now.subtract(const Duration(days: 29)),
    dueDate: _now.subtract(const Duration(days: 10)),
    subtotal: 5000,
    discountAmount: 500,
    taxAmount: 500,
    totalAmount: 5000,
    paidAmount: 2000,
    remainingAmount: 3000,
    currency: 'EGP',
    notes: 'Overdue invoice. Payment follow-up required.',
  ),

  // 7. CANCELLED
  // No financial actions
  InvoiceDetailModel(
    id: 'inv-007',
    invoiceNumber: 'INV-2026-007',
    visitId: 'visit-007',
    visitNumber: 'VIS-2026-007',
    client: _client,
    site: _site,
    paymentStatus: PaymentStatus.cancelled,
    createdAt: _now.subtract(const Duration(days: 6)),
    issueDate: null,
    dueDate: null,
    subtotal: 0,
    discountAmount: 0,
    taxAmount: 0,
    totalAmount: 0,
    paidAmount: 0,
    remainingAmount: 0,
    currency: 'EGP',
    notes: 'Visit cancelled before invoice issuance.',
  ),

  // 8. REFUNDED
  // No financial actions
  // Financial figures here are a historical invoice snapshot.
  InvoiceDetailModel(
    id: 'inv-008',
    invoiceNumber: 'INV-2026-008',
    visitId: 'visit-008',
    visitNumber: 'VIS-2026-008',
    client: _client,
    site: _site,
    paymentStatus: PaymentStatus.refunded,
    createdAt: _now.subtract(const Duration(days: 15)),
    issueDate: _now.subtract(const Duration(days: 14)),
    dueDate: _now.subtract(const Duration(days: 2)),
    subtotal: 800,
    discountAmount: 0,
    taxAmount: 0,
    totalAmount: 800,
    paidAmount: 800,
    remainingAmount: 0,
    currency: 'EGP',
    notes: 'Payment refunded. Historical paid amount shown.',
  ),

  // 9. INCOMPLETE DATA
  // Tests fallback values and missing-field handling
  InvoiceDetailModel(
    id: 'inv-009',
    invoiceNumber: 'INV-2026-009',
    visitId: 'visit-009',
    visitNumber: 'VIS-2026-009',
    client: null,
    site: null,
    paymentStatus: PaymentStatus.unpaid,
    createdAt: _now,
    issueDate: null,
    dueDate: null,
    subtotal: null,
    discountAmount: null,
    taxAmount: null,
    totalAmount: null,
    paidAmount: null,
    remainingAmount: null,
    currency: 'EGP',
    notes: null,
  ),

  // 10. INVALID FINANCIAL BALANCE
  // Tests financial validation and locking actions
  // Total - Paid != Remaining
  InvoiceDetailModel(
    id: 'inv-010',
    invoiceNumber: 'INV-2026-010',
    visitId: 'visit-010',
    visitNumber: 'VIS-2026-010',
    client: _client,
    site: _site,
    paymentStatus: PaymentStatus.partiallyPaid,
    createdAt: _now.subtract(const Duration(days: 3)),
    issueDate: _now.subtract(const Duration(days: 2)),
    dueDate: _now.add(const Duration(days: 5)),
    subtotal: 2000,
    discountAmount: 0,
    taxAmount: 0,
    totalAmount: 2000,
    paidAmount: 500,
    remainingAmount: 1800, // Intentionally wrong; should be 1500
    currency: 'EGP',
    notes: 'Invalid balance test. Actions should be blocked.',
  ),
];
