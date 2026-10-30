import 'package:visit_proof/core/utils/enums/payment_method_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_payment_history_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_history_model.dart';

/// UI-side document state. The uploaded invoice_status_enum.dart is commented
/// out. This MUST be supplied by the API mapping; never infer it from paymentStatus.
enum InvoiceDocumentState { draft, issued, cancelled }

enum InvoicePaymentEntryState { pending, confirmed, reversed }

enum InvoiceAction {
  create,
  editAmounts,
  issue,
  changeDueDate,
  recordPayment,
  confirmPayment,
  reversePayment,
  refundPayment,
  adjustBalance,
  cancelInvoice,
  addNote,
  downloadPdf,
  sendEmail,
  sendWhatsApp,
  viewPaymentHistory,
}

enum InvoiceAdjustmentKind { credit, debit }

/// Issued invoice original values remain immutable; adjustments are separate.
class InvoiceAppliedAdjustment {
  final String id;
  final InvoiceAdjustmentKind kind;
  final num amount;
  final DateTime date;
  final String reason;

  const InvoiceAppliedAdjustment({required this.id, required this.kind,
    required this.amount, required this.date, required this.reason});
}

/// Supplementary transaction status from the payment ledger API. The existing
/// InvoicePaymentHistoryModel doesn't include status/refund information.
class InvoicePaymentEntry {
  final InvoicePaymentHistoryModel payment;
  final InvoicePaymentEntryState state;
  final num refundedAmount;

  const InvoicePaymentEntry({
    required this.payment,
    required this.state,
    this.refundedAmount = 0,
  });

  String get id => payment.id ?? '';
  num get amount => payment.paymentAmount ?? 0;
  num get refundable => amount - refundedAmount;
}

/// This is display-only activity data, not a replacement for VisitHistory.
class InvoiceActivityEntry {
  final DateTime occurredAt;
  final String title;
  final String detail;
  final String actorName;

  const InvoiceActivityEntry({
    required this.occurredAt,
    required this.title,
    required this.detail,
    required this.actorName,
  });
}

/// Render only + validations. Do not treat a locally prepared command as saved.
/// Example API contract: POST /invoices/{id}/payments with [data].
class InvoiceActionCommand {
  final InvoiceAction action;
  final String visitId;
  final String? invoiceId;
  final String actorId;
  final Map<String, dynamic> data;

  const InvoiceActionCommand({
    required this.action,
    required this.visitId,
    required this.invoiceId,
    required this.actorId,
    required this.data,
  });
}

/// The caller provides a current, verified snapshot of invoice + visit + ledger.
/// In production, populate explicit booleans from permissions/approval APIs.
class InvoiceAdminContext {
  final VisitDetailModel visit;
  final InvoiceDetailModel? invoice;
  final InvoiceDocumentState? documentState;
  final VisitHistoryActorModel admin;
  final List<InvoicePaymentEntry> payments;
  final List<InvoiceActivityEntry> activities;
  final List<InvoiceAppliedAdjustment> adjustments;
  final bool adjustmentsLoaded;
  final bool paymentLedgerLoaded;
  final bool adminAuthorized;
  final bool dataIsFresh;
  final bool earlyIssueApproved;
  final bool priceOverrideApproved;
  final bool cancelledVisitCollectionApproved;
  final bool independentCancellationApproved;
  final bool pastDueDateApproved;

  const InvoiceAdminContext({
    required this.visit,
    required this.invoice,
    required this.documentState,
    required this.admin,
    this.payments = const [],
    this.activities = const [],
    this.adjustments = const [],
    this.adjustmentsLoaded = false,
    this.paymentLedgerLoaded = false,
    this.adminAuthorized = false,
    this.dataIsFresh = true,
    this.earlyIssueApproved = false,
    this.priceOverrideApproved = false,
    this.cancelledVisitCollectionApproved = false,
    this.independentCancellationApproved = false,
    this.pastDueDateApproved = false,
  });
}

class InvoiceDecision {
  final bool allowed;
  final String reason;
  const InvoiceDecision.allow() : allowed = true, reason = '';
  const InvoiceDecision.deny(this.reason) : allowed = false;
}

/// Immutable centralized rules; call before opening an action AND on submit.
class InvoiceAdminPolicy {
  final InvoiceAdminContext context;
  const InvoiceAdminPolicy(this.context);

  InvoiceDetailModel? get invoice => context.invoice;
  VisitDetailModel get visit => context.visit;
  InvoiceDocumentState? get stage => context.documentState;
  bool get exists => invoice != null;

  double get total => (invoice?.totalAmount ?? 0).toDouble();
  double get effectiveTotal => total + context.adjustments.fold<double>(0,
      (a, e) => a + e.amount.toDouble() *
          (e.kind == InvoiceAdjustmentKind.debit ? 1 : -1));
  double get paid => (invoice?.paidAmount ?? 0).toDouble();
  double get remaining => (invoice?.remainingAmount ?? (effectiveTotal - paid)).toDouble();
  double get pendingAmount => context.payments
      .where((e) => e.state == InvoicePaymentEntryState.pending)
      .fold<double>(0, (a, e) => a + e.amount.toDouble());
  double get freeToCollect => remaining - pendingAmount;
  double get confirmedNet => context.payments
      .where((e) => e.state == InvoicePaymentEntryState.confirmed)
      .fold<double>(0, (a, e) => a + e.refundable.toDouble());
  bool near(double a, double b) => (a - b).abs() <= 0.011;

  /// Do not unlock money actions on partially loaded or inconsistent ledgers.
  InvoiceDecision get ledgerHealth {
    if (!context.paymentLedgerLoaded) {
      return const InvoiceDecision.deny('سجل المدفوعات لم يكتمل تحميله');
    }
    if (!context.adjustmentsLoaded) {
      return const InvoiceDecision.deny('سجل التسويات المالية لم يكتمل تحميله');
    }
    if (context.adjustments.any((a) => a.id.trim().isEmpty || a.amount <= 0) ||
        context.adjustments.map((a) => a.id).toSet().length != context.adjustments.length) {
      return const InvoiceDecision.deny('سجل التسويات يحتوي بيانات ناقصة أو مكررة');
    }
    if (effectiveTotal < -0.011) {
      return const InvoiceDecision.deny('التسويات تتجاوز إجمالي الفاتورة');
    }
    if (context.payments.any((e) => e.id.isEmpty ||
        e.payment.invoiceId != invoice?.id || e.amount <= 0 ||
        e.refundedAmount < 0 || e.refundedAmount > e.amount ||
        (e.state != InvoicePaymentEntryState.confirmed && e.refundedAmount != 0))) {
      return const InvoiceDecision.deny('يوجد سجل دفع غير صالح أو مكرر الحالة');
    }
    if (context.payments.map((e) => e.id).toSet().length != context.payments.length) {
      return const InvoiceDecision.deny('هناك معاملات دفع مكررة');
    }
    if (!near(confirmedNet, paid)) {
      return const InvoiceDecision.deny('إجمالي المدفوعات لا يطابق سجل التحصيل؛ حدّث البيانات');
    }
    if (!near(effectiveTotal - paid, remaining) || remaining < -0.011) {
      return const InvoiceDecision.deny('رصيد الفاتورة غير متطابق؛ حدّث البيانات');
    }
    if (pendingAmount > remaining + 0.011) {
      return const InvoiceDecision.deny('المبالغ قيد التأكيد تتجاوز الرصيد المستحق');
    }
    return const InvoiceDecision.allow();
  }

  InvoiceDecision get documentHealth {
    if (!exists) return const InvoiceDecision.deny('الفاتورة غير موجودة');
    if (stage == null) return const InvoiceDecision.deny('حالة إصدار الفاتورة غير معروفة');
    if (invoice!.id == null || invoice!.id!.trim().isEmpty ||
        invoice!.visitId == null || invoice!.visitId!.trim().isEmpty ||
        visit.id == null || visit.id!.trim().isEmpty) {
      return const InvoiceDecision.deny('بيانات الربط بين الزيارة والفاتورة ناقصة');
    }
    if (invoice!.visitId != visit.id ||
        (visit.invoiceID != null && visit.invoiceID!.isNotEmpty &&
            visit.invoiceID != invoice!.id)) {
      return const InvoiceDecision.deny('الفاتورة غير مرتبطة بهذه الزيارة');
    }
    if (invoice!.client?.id != null && visit.client?.id != null &&
        invoice!.client!.id != visit.client!.id) {
      return const InvoiceDecision.deny('العميل في الفاتورة مختلف عن الزيارة');
    }
    return const InvoiceDecision.allow();
  }

  InvoiceDecision get moneyHealth {
    final i = invoice;
    if (i == null || i.subtotal == null || i.discountAmount == null ||
        i.taxAmount == null || i.totalAmount == null || i.paidAmount == null ||
        i.remainingAmount == null || i.currency?.trim().isNotEmpty != true) {
      return const InvoiceDecision.deny('المبالغ أو العملة غير مكتملة');
    }
    final subtotal = i.subtotal!.toDouble();
    final discount = i.discountAmount!.toDouble();
    final tax = i.taxAmount!.toDouble();
    if (subtotal <= 0 || discount < 0 || tax < 0 || discount > subtotal ||
        paid < 0 || !near(subtotal - discount + tax, total) ||
        total <= 0 || paid > total + 0.011) {
      return const InvoiceDecision.deny('إجمالي الفاتورة أو الخصم أو الضريبة غير صالح');
    }
    if (i.client?.id?.isNotEmpty != true || i.invoiceNumber?.isNotEmpty != true) {
      return const InvoiceDecision.deny('العميل أو رقم الفاتورة غير مكتمل');
    }
    return const InvoiceDecision.allow();
  }

  InvoiceDecision check(InvoiceAction action) {
    if (!context.adminAuthorized) {
      return const InvoiceDecision.deny('لا توجد صلاحية إدارة الفواتير');
    }
    if (context.admin.id?.isNotEmpty != true) {
      return const InvoiceDecision.deny('لم يتم التعرف على حساب الأدمن');
    }
    if (!context.dataIsFresh) {
      return const InvoiceDecision.deny('حدّث الفاتورة والزيارة قبل تنفيذ أي إجراء');
    }
    if (action == InvoiceAction.create) {
      if (exists || visit.invoiceID?.isNotEmpty == true) {
        return const InvoiceDecision.deny('الزيارة مرتبطة بفاتورة بالفعل');
      }
      return visit.id?.isNotEmpty == true
          ? const InvoiceDecision.allow()
          : const InvoiceDecision.deny('معرّف الزيارة مطلوب');
    }
    final linked = documentHealth;
    if (!linked.allowed) return linked;
    if (action == InvoiceAction.viewPaymentHistory) {
      return context.paymentLedgerLoaded
          ? const InvoiceDecision.allow()
          : const InvoiceDecision.deny('سجل الدفع لم يتم تحميله');
    }
    if (action == InvoiceAction.addNote) return const InvoiceDecision.allow();
    if (action == InvoiceAction.downloadPdf ||
        action == InvoiceAction.sendEmail || action == InvoiceAction.sendWhatsApp) {
      if (stage != InvoiceDocumentState.issued) {
        return const InvoiceDecision.deny('لا يمكن مشاركة فاتورة غير صادرة أو ملغاة');
      }
      if (action == InvoiceAction.sendEmail &&
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
              .hasMatch(invoice!.client?.email?.trim() ?? '')) {
        return const InvoiceDecision.deny('بريد العميل غير موجود أو غير صالح');
      }
      if (action == InvoiceAction.sendWhatsApp) {
        final digits = (invoice!.client?.phone ?? '').replaceAll(RegExp(r'\D'), '');
        if (invoice!.client?.isWhatsAppPhone != true || digits.length < 7 ||
            digits.length > 15) {
          return const InvoiceDecision.deny('رقم العميل غير صالح أو غير مفعّل للواتساب');
        }
      }
      return const InvoiceDecision.allow();
    }
    if (action == InvoiceAction.editAmounts) {
      if (stage != InvoiceDocumentState.draft) {
        return const InvoiceDecision.deny('المبالغ الأصلية لا تُعدل بعد إصدار الفاتورة');
      }
      if (paid > 0 || context.payments.isNotEmpty) {
        return const InvoiceDecision.deny('المسودة بها عمليات تحصيل؛ يلزم تصحيحها أولًا');
      }
      switch (visit.status) {
        case VisitStatus.draft:
        case VisitStatus.scheduled:
        case VisitStatus.assigned:
          return const InvoiceDecision.allow();
        case VisitStatus.onWay:
        case VisitStatus.inProgress:
          return context.priceOverrideApproved
              ? const InvoiceDecision.allow()
              : const InvoiceDecision.deny('مطلوب تصريح لتعديل السعر أثناء التنفيذ');
        default:
          return const InvoiceDecision.deny('حالة الزيارة لا تسمح بتعديل السعر');
      }
    }
    if (action == InvoiceAction.issue) {
      if (stage != InvoiceDocumentState.draft || visit.status == VisitStatus.cancel ||
          visit.status == VisitStatus.draft) {
        return const InvoiceDecision.deny('الإصدار يتطلب مسودة وزيارة غير ملغاة أو أولية');
      }
      final healthy = moneyHealth;
      if (!healthy.allowed) return healthy;
      if (invoice!.dueDate == null ||
          invoice!.dueDate!.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
        return const InvoiceDecision.deny('حدد تاريخ استحقاق صالحًا قبل إصدار الفاتورة');
      }
      if (visit.price != null && !near(visit.price!.toDouble(), invoice!.subtotal!.toDouble())) {
        return const InvoiceDecision.deny('سعر الخدمة غير متطابق بين الزيارة والفاتورة');
      }
      if ((invoice!.site?.addressDetail ?? '').trim() !=
          (visit.site?.addressDetail ?? '').trim()) {
        return const InvoiceDecision.deny('موقع الفاتورة غير متطابق مع الزيارة');
      }
      if (invoice!.issueDate != null) {
        return const InvoiceDecision.deny('تاريخ الإصدار مسجل بالفعل، راجع حالة المستند');
      }
      if (visit.status != VisitStatus.completed && !context.earlyIssueApproved) {
        return const InvoiceDecision.deny('الإصدار قبل اكتمال الزيارة يحتاج موافقة');
      }
      return const InvoiceDecision.allow();
    }
    if (action == InvoiceAction.changeDueDate) {
      if (stage == InvoiceDocumentState.cancelled) {
        return const InvoiceDecision.deny('لا يمكن تعديل استحقاق فاتورة ملغاة');
      }
      if (stage == InvoiceDocumentState.issued && remaining <= 0.011) {
        return const InvoiceDecision.deny('تمت تسوية الفاتورة بالكامل؛ لا حاجة لتغيير الاستحقاق');
      }
      return const InvoiceDecision.allow();
    }
    if (action == InvoiceAction.recordPayment) {
      if (stage != InvoiceDocumentState.issued) {
        return const InvoiceDecision.deny('يجب إصدار الفاتورة قبل التحصيل');
      }
      if (visit.status == VisitStatus.draft ||
          (visit.status == VisitStatus.cancel && !context.cancelledVisitCollectionApproved)) {
        return const InvoiceDecision.deny('حالة الزيارة لا تسمح بتحصيل جديد');
      }
      final ledger = ledgerHealth;
      if (!ledger.allowed) return ledger;
      return freeToCollect > 0.011
          ? const InvoiceDecision.allow()
          : const InvoiceDecision.deny('لا يوجد رصيد متاح للتحصيل، أو هناك دفعات معلقة');
    }
    if (action == InvoiceAction.confirmPayment ||
        action == InvoiceAction.reversePayment ||
        action == InvoiceAction.refundPayment) {
      final ledger = ledgerHealth;
      if (!ledger.allowed) return ledger;
      if (action == InvoiceAction.confirmPayment) {
        if (stage != InvoiceDocumentState.issued) {
          return const InvoiceDecision.deny('تأكيد الدفع يتطلب فاتورة صادرة');
        }
        return context.payments.any((e) => e.state == InvoicePaymentEntryState.pending)
            ? const InvoiceDecision.allow()
            : const InvoiceDecision.deny('لا توجد دفعات معلقة');
      }
      if (action == InvoiceAction.reversePayment) {
        return context.payments.any((e) =>
            e.refundedAmount == 0 && e.state != InvoicePaymentEntryState.reversed)
            ? const InvoiceDecision.allow()
            : const InvoiceDecision.deny('لا توجد دفعات قابلة للعكس');
      }
      return context.payments.any((e) =>
          e.state == InvoicePaymentEntryState.confirmed && e.refundable > 0)
          ? const InvoiceDecision.allow()
          : const InvoiceDecision.deny('لا توجد مبالغ محصلة قابلة للاسترداد');
    }
    if (action == InvoiceAction.adjustBalance) {
      if (stage != InvoiceDocumentState.issued) {
        return const InvoiceDecision.deny('التسوية المالية تخص الفاتورة الصادرة فقط');
      }
      final ledger = ledgerHealth;
      return ledger.allowed ? const InvoiceDecision.allow() : ledger;
    }
    if (action == InvoiceAction.cancelInvoice) {
      if (stage == InvoiceDocumentState.cancelled) {
        return const InvoiceDecision.deny('الفاتورة ملغاة بالفعل');
      }
      if (visit.status != VisitStatus.cancel && !context.independentCancellationApproved) {
        return const InvoiceDecision.deny('الإلغاء يتطلب إلغاء الزيارة أو تصريحًا ماليًا');
      }
      if (stage == InvoiceDocumentState.issued) {
        final ledger = ledgerHealth;
        if (!ledger.allowed) return ledger;
        if (paid > 0.011 || pendingAmount > 0.011) {
          return const InvoiceDecision.deny('يجب رد المبالغ وتصفية المدفوعات المعلقة قبل الإلغاء');
        }
      }
      return const InvoiceDecision.allow();
    }
    return const InvoiceDecision.deny('إجراء غير متاح');
  }

  InvoiceDecision checkPayment(InvoiceAction action, InvoicePaymentEntry entry) {
    final general = check(action);
    if (!general.allowed) return general;
    if (!context.payments.contains(entry) &&
        !context.payments.any((e) => e.id == entry.id)) {
      return const InvoiceDecision.deny('عملية الدفع غير مرتبطة بهذه الفاتورة');
    }
    if (action == InvoiceAction.confirmPayment) {
      if (entry.state != InvoicePaymentEntryState.pending) {
        return const InvoiceDecision.deny('يُسمح فقط بتأكيد الدفعات المعلقة');
      }
      if (entry.amount > remaining + 0.011) {
        return const InvoiceDecision.deny('تأكيد هذه الدفعة سيتجاوز الرصيد المستحق');
      }
    }
    if (action == InvoiceAction.reversePayment &&
        (entry.state == InvoicePaymentEntryState.reversed || entry.refundedAmount > 0)) {
      return const InvoiceDecision.deny('دفعة معكوسة أو تم رد جزء منها');
    }
    if (action == InvoiceAction.refundPayment &&
        (entry.state != InvoicePaymentEntryState.confirmed || entry.refundable <= 0)) {
      return const InvoiceDecision.deny('الدفعة غير مؤكدة أو مستردة بالكامل');
    }
    return const InvoiceDecision.allow();
  }

  /// Ensures exact two-decimal amount; use integer minor-units for the command.
  static int? toMinorUnits(String raw) {
    final clean = raw.trim();
    if (!RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(clean)) return null;
    final parts = clean.split('.');
    final whole = int.tryParse(parts[0]);
    if (whole == null) return null;
    final decimals = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
    return whole * 100 + int.parse(decimals);
  }

  static int minor(num amount) => (amount * 100).round();

  InvoiceDecision validateMoneyEdit({
    required String subtotal,
    required String discount,
    required String tax,
    required String reason,
  }) {
    final permission = check(InvoiceAction.editAmounts);
    if (!permission.allowed) return permission;
    final s = toMinorUnits(subtotal), d = toMinorUnits(discount), t = toMinorUnits(tax);
    if (s == null || d == null || t == null || s <= 0 || d < 0 || d > s) {
      return const InvoiceDecision.deny('ادخل أسعارًا صحيحة، والخصم لا يتجاوز قيمة الخدمة');
    }
    if (s - d + t <= 0) {
      return const InvoiceDecision.deny('إجمالي الفاتورة يجب أن يكون أكبر من صفر');
    }
    if (s == minor(invoice?.subtotal ?? 0) &&
        d == minor(invoice?.discountAmount ?? 0) &&
        t == minor(invoice?.taxAmount ?? 0)) {
      return const InvoiceDecision.deny('لم يتم تغيير أي مبلغ');
    }
    if (reason.trim().length < 5) {
      return const InvoiceDecision.deny('سبب التعديل مطلوب (5 أحرف على الأقل)');
    }
    return const InvoiceDecision.allow();
  }

  InvoiceDecision validateDueDate(DateTime? date, String reason) {
    final permission = check(InvoiceAction.changeDueDate);
    if (!permission.allowed) return permission;
    if (date == null) return const InvoiceDecision.deny('اختر تاريخ الاستحقاق');
    final old = invoice?.dueDate;
    if (old != null && date.year == old.year && date.month == old.month &&
        date.day == old.day) {
      return const InvoiceDecision.deny('تاريخ الاستحقاق لم يتغير');
    }
    final issue = invoice?.issueDate ?? DateTime.now();
    final start = DateTime(issue.year, issue.month, issue.day);
    if (date.isBefore(start) && !context.pastDueDateApproved) {
      return const InvoiceDecision.deny('الاستحقاق لا يسبق تاريخ الإصدار/اليوم بدون تصريح');
    }
    if (stage == InvoiceDocumentState.issued && reason.trim().length < 5) {
      return const InvoiceDecision.deny('سبب تعديل تاريخ الفاتورة الصادرة مطلوب');
    }
    return const InvoiceDecision.allow();
  }

  InvoiceDecision validatePayment({
    required String amount,
    required PaymentMethod? method,
    required DateTime? date,
    required String reference,
  }) {
    final permission = check(InvoiceAction.recordPayment);
    if (!permission.allowed) return permission;
    final value = toMinorUnits(amount);
    if (value == null || value <= 0 || value > minor(freeToCollect)) {
      return const InvoiceDecision.deny('المبلغ غير صالح أو يتجاوز المتاح بعد خصم الدفعات المعلقة');
    }
    if (method == null || date == null) {
      return const InvoiceDecision.deny('اختر وسيلة وتاريخ الدفع');
    }
    if (date.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return const InvoiceDecision.deny('لا يمكن تسجيل دفعة بتاريخ مستقبلي');
    }
    if (invoice?.issueDate != null &&
        DateTime(date.year, date.month, date.day).isBefore(DateTime(
          invoice!.issueDate!.year, invoice!.issueDate!.month, invoice!.issueDate!.day))) {
      return const InvoiceDecision.deny('تاريخ الدفع لا يسبق تاريخ إصدار الفاتورة');
    }
    if (method != PaymentMethod.cash && reference.trim().isEmpty) {
      return const InvoiceDecision.deny('الرقم المرجعي مطلوب لوسيلة الدفع المختارة');
    }
    if (reference.trim().length > 120) {
      return const InvoiceDecision.deny('الرقم المرجعي طويل جدًا');
    }
    if (method != PaymentMethod.cash && context.payments.any((e) =>
        e.state != InvoicePaymentEntryState.reversed &&
        e.payment.paymentMethod == method &&
        e.payment.referenceNumber?.trim().toLowerCase() == reference.trim().toLowerCase())) {
      return const InvoiceDecision.deny('المرجع مستخدم بالفعل في معاملة سابقة');
    }
    return const InvoiceDecision.allow();
  }

  InvoiceDecision validateRefund(InvoicePaymentEntry e, String amount, String reason) {
    final permission = checkPayment(InvoiceAction.refundPayment, e);
    if (!permission.allowed) return permission;
    final value = toMinorUnits(amount);
    if (value == null || value <= 0 || value > minor(e.refundable)) {
      return const InvoiceDecision.deny('مبلغ الاسترداد لا يتجاوز رصيد الدفعة القابل للاسترداد');
    }
    return _requireReason(reason);
  }

  InvoiceDecision validateAdjustment(InvoiceAdjustmentKind kind, String amount, String reason) {
    final permission = check(InvoiceAction.adjustBalance);
    if (!permission.allowed) return permission;
    final value = toMinorUnits(amount);
    if (value == null || value <= 0) {
      return const InvoiceDecision.deny('مبلغ التسوية يجب أن يكون موجبًا');
    }
    if (kind == InvoiceAdjustmentKind.credit &&
        minor(effectiveTotal) - value < minor(paid + pendingAmount)) {
      return const InvoiceDecision.deny('التخفيض سيجعل الإجمالي أقل من المدفوعات والمبالغ المعلقة');
    }
    return _requireReason(reason);
  }

  InvoiceDecision validateReasonAction(InvoiceAction action, String reason,
      {InvoicePaymentEntry? payment, bool verified = false}) {
    final permission = payment == null ? check(action) : checkPayment(action, payment);
    if (!permission.allowed) return permission;
    if (action == InvoiceAction.confirmPayment && !verified) {
      return const InvoiceDecision.deny('يجب تأكيد التحقق من وصول المبلغ فعليًا');
    }
    if (action == InvoiceAction.create || action == InvoiceAction.issue ||
        action == InvoiceAction.confirmPayment ||
        action == InvoiceAction.downloadPdf ||
        action == InvoiceAction.sendEmail || action == InvoiceAction.sendWhatsApp) {
      return const InvoiceDecision.allow();
    }
    return _requireReason(reason);
  }

  InvoiceDecision _requireReason(String reason) {
    if (reason.trim().length < 5) {
      return const InvoiceDecision.deny('السبب مطلوب (5 أحرف على الأقل)');
    }
    if (reason.trim().length > 2000) {
      return const InvoiceDecision.deny('نص السبب طويل جدًا');
    }
    return const InvoiceDecision.allow();
  }
}
