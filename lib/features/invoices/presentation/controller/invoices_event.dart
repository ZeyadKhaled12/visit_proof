part of 'invoices_bloc.dart';

abstract class InvoicesEvent extends Equatable {
  const InvoicesEvent();

  @override
  List<Object> get props => [];
}

class GetInvoicesEvent extends InvoicesEvent {
  final NoParameters noParameters;
  const GetInvoicesEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class GetCreateInvoiceEvent extends InvoicesEvent {
  final GetCreateInvoiceParameters getCreateInvoiceParameters;
  const GetCreateInvoiceEvent({required this.getCreateInvoiceParameters});
  @override
  List<Object> get props => [getCreateInvoiceParameters];
}

class GetInvoiceDetailEvent extends InvoicesEvent {
  final GetInvoiceDetailParameters getInvoiceDetailParameters;
  const GetInvoiceDetailEvent({required this.getInvoiceDetailParameters});
  @override
  List<Object> get props => [getInvoiceDetailParameters];
}

class IssueInvoiceEvent extends InvoicesEvent {
  final IssueInvoiceParameters issueInvoiceParameters;
  const IssueInvoiceEvent({required this.issueInvoiceParameters});
  @override
  List<Object> get props => [issueInvoiceParameters];
}

class RecordPaymentEvent extends InvoicesEvent {
  final RecordPaymentParameters recordPaymentParameters;
  const RecordPaymentEvent({required this.recordPaymentParameters});
  @override
  List<Object> get props => [recordPaymentParameters];
}

class RefundPaymentEvent extends InvoicesEvent {
  final RefundPaymentParameters refundPaymentParameters;
  const RefundPaymentEvent({required this.refundPaymentParameters});
  @override
  List<Object> get props => [refundPaymentParameters];
}

class UpdateDraftInvoiceEvent extends InvoicesEvent {
  final UpdateDraftInvoiceParameters updateDraftInvoiceParameters;
  const UpdateDraftInvoiceEvent({required this.updateDraftInvoiceParameters});
  @override
  List<Object> get props => [updateDraftInvoiceParameters];
}
