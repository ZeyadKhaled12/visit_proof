import 'package:either_dart/either.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_create_invoice_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_invoice_detail_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/issue_invoice_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/record_payment_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/refund_payment_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/update_draft_invoice_uc.dart';

import '../../data/models/invoice_payment_history_model.dart';
import '../usecases/get_payments_uc.dart';
import '../usecases/review_payment_uc.dart';

import '../../../../core/network/error/failure.dart';

abstract class BaseInvoicesRepo {
  Future<Either<Failure, InvoiceDetailModel>> getCreateInvoice(
      GetCreateInvoiceParameters parameters);
  Future<Either<Failure, InvoiceDetailModel>> getInvoiceDetail(
      GetInvoiceDetailParameters parameters);
  Future<Either<Failure, InvoiceDetailModel>> issueInvoice(
      IssueInvoiceParameters parameters);
  Future<Either<Failure, InvoiceDetailModel>> recordPayment(
      RecordPaymentParameters parameters);
  Future<Either<Failure, InvoiceDetailModel>> refundPayment(
      RefundPaymentParameters parameters);
  Future<Either<Failure, InvoiceDetailModel>> updateDraftInvoice(
      UpdateDraftInvoiceParameters parameters);
  Future<Either<Failure, List<InvoiceDetailModel>>> getInvoices(
      NoParameters parameters);
  Future<Either<Failure, InvoiceDetailModel>> reviewPayment(
      ReviewPaymentParameters parameters);
  Future<Either<Failure, List<InvoicePaymentHistoryModel>>> getPayments(
      GetPaymentsParameters parameters);
}
