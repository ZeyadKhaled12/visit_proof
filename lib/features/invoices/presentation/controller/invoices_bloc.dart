import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_create_invoice_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_invoices_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/record_payment_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/refund_payment_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/update_draft_invoice_uc.dart';

import '../../../../core/utils/enums.dart';
import '../../data/models/invoice_payment_history_model.dart';
import '../../domain/usecases/get_payments_uc.dart';
import '../../domain/usecases/review_payment_uc.dart';
import '../../domain/usecases/get_invoice_detail_uc.dart';
import '../../domain/usecases/issue_invoice_uc.dart';

part 'invoices_event.dart';
part 'invoices_state.dart';

class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  final GetInvoicesUc getInvoicesUc;
  final GetCreateInvoiceUc getCreateInvoiceUc;
  final GetInvoiceDetailUc getInvoiceDetailUc;
  final IssueInvoiceUc issueInvoiceUc;
  final RecordPaymentUc recordPaymentUc;
  final RefundPaymentUc refundPaymentUc;
  final UpdateDraftInvoiceUc updateDraftInvoiceUc;
  final ReviewPaymentUc reviewPaymentUc;
  final GetPaymentsUc getPaymentsUc;

  /// The last payments list asked for, reloaded after every review.
  GetPaymentsParameters? _paymentsQuery;

  InvoicesBloc(
      this.getCreateInvoiceUc,
      this.getInvoiceDetailUc,
      this.issueInvoiceUc,
      this.recordPaymentUc,
      this.refundPaymentUc,
      this.updateDraftInvoiceUc,
      this.getInvoicesUc,
      this.reviewPaymentUc,
      this.getPaymentsUc)
      : super(InvoicesState()) {
    on<GetInvoicesEvent>(_getInvoices);
    on<GetCreateInvoiceEvent>(_getCreateInvoice);
    on<GetInvoiceDetailEvent>(_getInvoiceDetail);
    on<IssueInvoiceEvent>(_issueInvoice);
    on<RecordPaymentEvent>(_recordPayment);
    on<RefundPaymentEvent>(_refundPayment);
    on<UpdateDraftInvoiceEvent>(_updateDraftInvoice);
    on<GetPaymentsEvent>(_getPayments);
    on<ReviewPaymentEvent>(_reviewPayment);
  }

  FutureOr<void> _getPayments(
      GetPaymentsEvent event, Emitter<InvoicesState> emit) async {
    _paymentsQuery = event.getPaymentsParameters;
    await _loadPayments(emit);
  }

  Future<void> _loadPayments(Emitter<InvoicesState> emit) async {
    final query = _paymentsQuery;
    if (query == null) return;
    emit(state.copyWith(paymentsRequestState: RequestState.loading));
    final result = await getPaymentsUc.call(query);
    result.fold(
        (l) => emit(state.copyWith(paymentsRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            paymentsRequestState: RequestState.loaded, payments: r)));
  }

  /// Confirms or rejects a field collection, then reloads the payments.
  FutureOr<void> _reviewPayment(
      ReviewPaymentEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(reviewPaymentRequestState: RequestState.loading));
    final result = await reviewPaymentUc.call(event.reviewPaymentParameters);
    if (result.isLeft) {
      emit(state.copyWith(reviewPaymentRequestState: RequestState.error));
      return;
    }
    final invoice = result.right;
    emit(state.copyWith(
      reviewPaymentRequestState: RequestState.loaded,
      invoiceDetailModel:
          state.invoiceDetailModel.id == invoice.id ? invoice : null,
      invoices: [
        for (final item in state.invoices) item.id == invoice.id ? invoice : item
      ],
    ));
    await _loadPayments(emit);
  }

  FutureOr<void> _getInvoices(
      GetInvoicesEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(invoicesRequestState: RequestState.loading));
    final result = await getInvoicesUc.call(event.noParameters);
    result.fold(
        (l) => emit(state.copyWith(invoicesRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            invoicesRequestState: RequestState.loaded, invoices: r)));
  }

  FutureOr<void> _getCreateInvoice(
      GetCreateInvoiceEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(invoiceDetailRequestState: RequestState.loading));
    final result =
        await getCreateInvoiceUc.call(event.getCreateInvoiceParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(invoiceDetailRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            invoiceDetailRequestState: RequestState.loaded,
            invoiceDetailModel: r)));
  }

  FutureOr<void> _getInvoiceDetail(
      GetInvoiceDetailEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(invoiceDetailRequestState: RequestState.loading));
    final result =
        await getInvoiceDetailUc.call(event.getInvoiceDetailParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(invoiceDetailRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            invoiceDetailRequestState: RequestState.loaded,
            invoiceDetailModel: r)));
  }

  FutureOr<void> _issueInvoice(
      IssueInvoiceEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(invoiceDetailRequestState: RequestState.loading));
    final result = await issueInvoiceUc.call(event.issueInvoiceParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(invoiceDetailRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            invoiceDetailRequestState: RequestState.loaded,
            invoiceDetailModel: r)));
  }

  FutureOr<void> _recordPayment(
      RecordPaymentEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(invoiceDetailRequestState: RequestState.loading));
    final result = await recordPaymentUc.call(event.recordPaymentParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(invoiceDetailRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            invoiceDetailRequestState: RequestState.loaded,
            invoiceDetailModel: r)));
  }

  FutureOr<void> _refundPayment(
      RefundPaymentEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(invoiceDetailRequestState: RequestState.loading));
    final result = await refundPaymentUc.call(event.refundPaymentParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(invoiceDetailRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            invoiceDetailRequestState: RequestState.loaded,
            invoiceDetailModel: r)));
  }

  FutureOr<void> _updateDraftInvoice(
      UpdateDraftInvoiceEvent event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(invoiceDetailRequestState: RequestState.loading));
    final result =
        await updateDraftInvoiceUc.call(event.updateDraftInvoiceParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(invoiceDetailRequestState: RequestState.error)),
        (r) {
      emit(state.copyWith(
          invoiceDetailRequestState: RequestState.loaded,
          invoiceDetailModel: r));
    });
  }
}
