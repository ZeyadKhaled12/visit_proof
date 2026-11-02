import 'package:either_dart/either.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/invoices/data/data_sources/invoices_remote_data_source.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/domain/repository/base_invoices_repo.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_create_invoice_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_invoice_detail_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/issue_invoice_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/record_payment_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/refund_payment_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/update_draft_invoice_uc.dart';

import '../../../../core/network/error/exception.dart';
import '../../domain/usecases/get_payments_uc.dart';
import '../../domain/usecases/review_payment_uc.dart';
import '../models/invoice_payment_history_model.dart';

class InvoicesRepo extends BaseInvoicesRepo {
  final BaseInvoicesRemoteDataSource baseInvoicesRemoteDataSource;

  InvoicesRepo(this.baseInvoicesRemoteDataSource);

  @override
  Future<Either<Failure, InvoiceDetailModel>> getCreateInvoice(
      GetCreateInvoiceParameters parameters) async {
    try {
      final result =
          await baseInvoicesRemoteDataSource.getOrCreateInvoice(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailModel>> getInvoiceDetail(
      GetInvoiceDetailParameters parameters) async {
    try {
      final result =
          await baseInvoicesRemoteDataSource.getInvoiceDetail(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailModel>> issueInvoice(
      IssueInvoiceParameters parameters) async {
    try {
      final result =
          await baseInvoicesRemoteDataSource.issueInvoice(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailModel>> recordPayment(
      RecordPaymentParameters parameters) async {
    try {
      final result =
          await baseInvoicesRemoteDataSource.recordPayment(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailModel>> refundPayment(
      RefundPaymentParameters parameters) async {
    try {
      final result =
          await baseInvoicesRemoteDataSource.refundPayment(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailModel>> updateDraftInvoice(
      UpdateDraftInvoiceParameters parameters) async {
    try {
      final result =
          await baseInvoicesRemoteDataSource.updateDraftInvoice(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceDetailModel>>> getInvoices(
      NoParameters parameters) async {
    try {
      final result = await baseInvoicesRemoteDataSource.getInvoices(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailModel>> reviewPayment(
      ReviewPaymentParameters parameters) async {
    try {
      final result =
          await baseInvoicesRemoteDataSource.reviewPayment(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, List<InvoicePaymentHistoryModel>>> getPayments(
      GetPaymentsParameters parameters) async {
    try {
      final result = await baseInvoicesRemoteDataSource.getPayments(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }
}
