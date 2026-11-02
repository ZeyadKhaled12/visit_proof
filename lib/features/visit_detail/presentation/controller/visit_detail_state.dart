part of 'visit_detail_bloc.dart';

class VisitDetailState extends Equatable {
  final VisitDetailModel visit;
  final InvoiceDetailModel invoice;
  final List<TechnicianModel> technicians;
  final List<ServiceModel> services;
  final RequestState getVisitDetailRequestState;
  final RequestState getInvoiceRequestState;
  final RequestState getTechniciansRequestState;
  final RequestState getServicesRequestState;
  final RequestState changeStatusRequestState;
  final RequestState assignTechnicianRequestState;
  final RequestState unassignTechnicianRequestState;
  final RequestState rescheduleRequestState;
  final RequestState updateInfoRequestState;
  final RequestState changeServiceRequestState;
  final RequestState changeSiteRequestState;
  final RequestState addCommentRequestState;
  final RequestState deleteVisitRequestState;
  final RequestState collectPaymentRequestState;

  const VisitDetailState({
    this.visit = const VisitDetailModel(),
    this.invoice = const InvoiceDetailModel(),
    this.technicians = const [],
    this.services = const [],
    this.getVisitDetailRequestState = RequestState.loaded,
    this.getInvoiceRequestState = RequestState.loaded,
    this.getTechniciansRequestState = RequestState.loaded,
    this.getServicesRequestState = RequestState.loaded,
    this.changeStatusRequestState = RequestState.loaded,
    this.assignTechnicianRequestState = RequestState.loaded,
    this.unassignTechnicianRequestState = RequestState.loaded,
    this.rescheduleRequestState = RequestState.loaded,
    this.updateInfoRequestState = RequestState.loaded,
    this.changeServiceRequestState = RequestState.loaded,
    this.changeSiteRequestState = RequestState.loaded,
    this.addCommentRequestState = RequestState.loaded,
    this.deleteVisitRequestState = RequestState.loaded,
    this.collectPaymentRequestState = RequestState.loaded,
  });

  /// The visit has been loaded at least once.
  bool get hasVisit => visit.id != null;

  /// The linked invoice, or null while it is missing or not loaded yet.
  InvoiceDetailModel? get linkedInvoice => invoice.id == null ? null : invoice;

  VisitDetailState copyWith({
    VisitDetailModel? visit,
    InvoiceDetailModel? invoice,
    List<TechnicianModel>? technicians,
    List<ServiceModel>? services,
    RequestState? getVisitDetailRequestState,
    RequestState? getInvoiceRequestState,
    RequestState? getTechniciansRequestState,
    RequestState? getServicesRequestState,
    RequestState? changeStatusRequestState,
    RequestState? assignTechnicianRequestState,
    RequestState? unassignTechnicianRequestState,
    RequestState? rescheduleRequestState,
    RequestState? updateInfoRequestState,
    RequestState? changeServiceRequestState,
    RequestState? changeSiteRequestState,
    RequestState? addCommentRequestState,
    RequestState? deleteVisitRequestState,
    RequestState? collectPaymentRequestState,
  }) {
    return VisitDetailState(
      visit: visit ?? this.visit,
      invoice: invoice ?? this.invoice,
      technicians: technicians ?? this.technicians,
      services: services ?? this.services,
      getVisitDetailRequestState:
          getVisitDetailRequestState ?? this.getVisitDetailRequestState,
      getInvoiceRequestState:
          getInvoiceRequestState ?? this.getInvoiceRequestState,
      getTechniciansRequestState:
          getTechniciansRequestState ?? this.getTechniciansRequestState,
      getServicesRequestState:
          getServicesRequestState ?? this.getServicesRequestState,
      changeStatusRequestState:
          changeStatusRequestState ?? this.changeStatusRequestState,
      assignTechnicianRequestState:
          assignTechnicianRequestState ?? this.assignTechnicianRequestState,
      unassignTechnicianRequestState:
          unassignTechnicianRequestState ?? this.unassignTechnicianRequestState,
      rescheduleRequestState:
          rescheduleRequestState ?? this.rescheduleRequestState,
      updateInfoRequestState:
          updateInfoRequestState ?? this.updateInfoRequestState,
      changeServiceRequestState:
          changeServiceRequestState ?? this.changeServiceRequestState,
      changeSiteRequestState:
          changeSiteRequestState ?? this.changeSiteRequestState,
      addCommentRequestState:
          addCommentRequestState ?? this.addCommentRequestState,
      deleteVisitRequestState:
          deleteVisitRequestState ?? this.deleteVisitRequestState,
      collectPaymentRequestState:
          collectPaymentRequestState ?? this.collectPaymentRequestState,
    );
  }

  @override
  List<Object> get props => [
        visit,
        invoice,
        technicians,
        services,
        getVisitDetailRequestState,
        getInvoiceRequestState,
        getTechniciansRequestState,
        getServicesRequestState,
        changeStatusRequestState,
        assignTechnicianRequestState,
        unassignTechnicianRequestState,
        rescheduleRequestState,
        updateInfoRequestState,
        changeServiceRequestState,
        changeSiteRequestState,
        addCommentRequestState,
        deleteVisitRequestState,
        collectPaymentRequestState,
      ];
}
