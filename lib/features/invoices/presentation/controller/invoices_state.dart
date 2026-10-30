part of 'invoices_bloc.dart';

class InvoicesState extends Equatable {
  final List<InvoiceDetailModel> invoices;
  final InvoiceDetailModel invoiceDetailModel;
  final RequestState invoiceDetailRequestState;
  final RequestState invoicesRequestState;

  const InvoicesState(
      {this.invoices = const [],
      this.invoiceDetailModel = const InvoiceDetailModel(),
      this.invoiceDetailRequestState = RequestState.loaded,
      this.invoicesRequestState = RequestState.loaded});

  InvoicesState copyWith(
      {List<InvoiceDetailModel>? invoices,
      InvoiceDetailModel? invoiceDetailModel,
      RequestState? invoiceDetailRequestState,
      RequestState? invoicesRequestState}) {
    return InvoicesState(
      invoices: invoices ?? this.invoices,
      invoiceDetailModel: invoiceDetailModel ?? this.invoiceDetailModel,
      invoiceDetailRequestState:
          invoiceDetailRequestState ?? this.invoiceDetailRequestState,
      invoicesRequestState: invoicesRequestState ?? this.invoicesRequestState,
    );
  }

  @override
  List<Object> get props => [
        invoices,
        invoiceDetailModel,
        invoiceDetailRequestState,
        invoicesRequestState
      ];
}
