part of 'invoices_bloc.dart';

class InvoicesState extends Equatable {
  final List<InvoiceDetailModel> invoices;
  final InvoiceDetailModel invoiceDetailModel;
  final List<InvoicePaymentHistoryModel> payments;
  final RequestState invoiceDetailRequestState;
  final RequestState invoicesRequestState;
  final RequestState paymentsRequestState;
  final RequestState reviewPaymentRequestState;

  const InvoicesState(
      {this.invoices = const [],
      this.invoiceDetailModel = const InvoiceDetailModel(),
      this.payments = const [],
      this.invoiceDetailRequestState = RequestState.loaded,
      this.invoicesRequestState = RequestState.loaded,
      this.paymentsRequestState = RequestState.loaded,
      this.reviewPaymentRequestState = RequestState.loaded});

  InvoicesState copyWith(
      {List<InvoiceDetailModel>? invoices,
      InvoiceDetailModel? invoiceDetailModel,
      List<InvoicePaymentHistoryModel>? payments,
      RequestState? invoiceDetailRequestState,
      RequestState? invoicesRequestState,
      RequestState? paymentsRequestState,
      RequestState? reviewPaymentRequestState}) {
    return InvoicesState(
      invoices: invoices ?? this.invoices,
      invoiceDetailModel: invoiceDetailModel ?? this.invoiceDetailModel,
      payments: payments ?? this.payments,
      invoiceDetailRequestState:
          invoiceDetailRequestState ?? this.invoiceDetailRequestState,
      invoicesRequestState: invoicesRequestState ?? this.invoicesRequestState,
      paymentsRequestState: paymentsRequestState ?? this.paymentsRequestState,
      reviewPaymentRequestState:
          reviewPaymentRequestState ?? this.reviewPaymentRequestState,
    );
  }

  @override
  List<Object> get props => [
        invoices,
        invoiceDetailModel,
        payments,
        invoiceDetailRequestState,
        invoicesRequestState,
        paymentsRequestState,
        reviewPaymentRequestState
      ];
}
