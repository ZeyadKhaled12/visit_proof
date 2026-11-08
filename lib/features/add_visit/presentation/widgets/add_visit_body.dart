import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/configs/app_theme.dart';
import 'package:visit_proof/core/demo/demo_mode.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/features/add_visit/domain/usecases/add_visit_uc.dart';
import 'package:visit_proof/features/add_visit/presentation/controller/add_visit_bloc.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../../services/data/models/service_model.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_client_model.dart';
import 'add_visit_widget_client.dart';
import 'add_visit_widget_schedule.dart';
import 'add_visit_widget_service.dart';

class AddVisitBody extends StatefulWidget {
  const AddVisitBody(
      {super.key,
      required this.clients,
      required this.clientsLoading,
      required this.services,
      required this.servicesLoading,
      required this.technicians,
      required this.technicansLoading,
      required this.addVisitLoading});
  final List<VisitClientModel> clients;
  final List<ServiceModel> services;
  final List<TechnicianModel> technicians;
  final bool clientsLoading;
  final bool servicesLoading;
  final bool technicansLoading;
  final bool addVisitLoading;

  @override
  State<AddVisitBody> createState() => _AddVisitBodyState();
}

class _AddVisitBodyState extends State<AddVisitBody> {
  VisitClientModel? _selectedClient;
  GModelSite? _selectedSite;
  ServiceModel? _selectedService;
  Priority? _selectedPriority;
  TechnicianModel? _selectedTechnician;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  bool _requiresBeforePhotos = false;
  bool _requiresAfterPhotos = false;
  final TextEditingController _problem = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  //all data picked from
  List<VisitClientModel> _allClients = [];
  List<GModelSite> _allSites = [];
  List<ServiceModel> _allServices = [];
  List<TechnicianModel> _allTechnicians = [];

  //errors
  String? _clientErrorMsg;
  String? _siteErrorMsg;
  String? _serviceErrorMsg;
  String? _startDateErrorMsg;
  String? _startTimeErrorMsg;

  //keys
  final GlobalKey _clientKey = GlobalKey();
  final GlobalKey _serviceKey = GlobalKey();
  final GlobalKey _startDateKey = GlobalKey();

  VisitStatus _status = VisitStatus.draft;
  bool _prefilled = false;

  @override
  void initState() {
    _selectedPriority = Priority.normal;
    super.initState();
  }

  @override
  void dispose() {
    _problem.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AddVisitBody oldWidget) {
    if (oldWidget.clientsLoading != widget.clientsLoading &&
        !widget.clientsLoading) {
      setState(() {
        _allClients = List.from(widget.clients);
      });
    }
    if (oldWidget.servicesLoading != widget.servicesLoading &&
        !widget.servicesLoading) {
      setState(() {
        _allServices = List.from(widget.services);
      });
    }
    if (oldWidget.technicansLoading != widget.technicansLoading &&
        !widget.technicansLoading) {
      setState(() {
        _allTechnicians = List.from(widget.technicians);
      });
    }
    _prefillForDemo();
    super.didUpdateWidget(oldWidget);
  }

  /// In the website's guide the form starts filled with sample data.
  void _prefillForDemo() {
    if (!DemoMode.prefillNewVisit || _prefilled) return;
    final client = widget.clients
        .where((e) => (e.sites ?? const []).isNotEmpty)
        .firstOrNull;
    if (client == null || widget.services.isEmpty) return;
    _prefilled = true;
    _allClients = List.from(widget.clients);
    _allServices = List.from(widget.services);
    // Tomorrow morning is inside working hours whenever the site is opened.
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    setState(() {
      _selectedClient = client;
      _allSites = client.sites!;
      _selectedSite = client.sites!.first;
      _selectedService = _allServices.first;
      _startDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      _startTime = const TimeOfDay(hour: 10, minute: 0);
    });
  }

  void _moveList(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// The picked date with the picked time, so the visit keeps both.
  DateTime? get _startDateTime {
    final date = _startDate;
    if (date == null) return null;
    final time = _startTime ?? const TimeOfDay(hour: 0, minute: 0);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _addVisit(VisitStatus status) {
    setState(() {
      _status = status;
    });
    VisitDetailModel visit = VisitDetailModel(
        client: _selectedClient,
        site: _selectedSite,
        category: _selectedService?.category,
        price: _selectedService?.defaultPrice,
        durationInMin: _selectedService?.duration,
        checkList: _selectedService?.checkList,
        priority: _selectedPriority,
        startDate: _startDateTime,
        notes: _notes.text.isEmpty ? null : _notes.text,
        problemDescription: _problem.text.isEmpty ? null : _problem.text,
        requireAfterWorkPhotos: _requiresAfterPhotos,
        requireBeforeWorkPhotos: _requiresBeforePhotos,
        technicianModel: _selectedTechnician,
        serviceName: _selectedService?.serviceName,
        paymentStatus: PaymentStatus.unpaid,
        status: status);
    context.read<AddVisitBloc>().add(AddNewVisitEvent(
        addVisitParameters: AddVisitParameters(visitDetailModel: visit)));
  }

  @override
  Widget build(BuildContext context) {
    return GWidgetNaviBody(
        title: 'Add Visit'.tr,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  GTourTarget(id: 'client', child: AddVisitWidgetClient(
                    key: _clientKey,
                    clients: _allClients,
                    sites: _allSites,
                    loading: widget.clientsLoading,
                    selectedClient: _selectedClient,
                    selectedSite: _selectedSite,
                    clientErrorMsg: _clientErrorMsg,
                    siteErrorMsg: _siteErrorMsg,
                    onClientChanged: (client, {isNewClient}) {
                      if (client?.id == _selectedClient?.id) return;
                      setState(() {
                        _selectedClient = client;
                        _selectedSite = null;
                        if (isNewClient == true) {
                          _allClients.add(client!);
                        }
                        _allSites = _selectedClient?.sites ?? [];
                        _clientErrorMsg = null;
                      });
                    },
                    onSiteChanged: (site, {index, isNewSite}) {
                      setState(() {
                        _selectedSite = site;
                        if (isNewSite == true) {
                          _allSites.add(site!);
                        }
                        if (index != null) {
                          _allSites[index] = site!;
                        }
                        _siteErrorMsg = null;
                      });
                    },
                  )),
                  SizedBox(height: 32),
                  GTourTarget(id: 'service', child: AddVisitWidgetService(
                    key: _serviceKey,
                    services: _allServices,
                    selectedService: _selectedService,
                    requiresBeforePhotos: _requiresBeforePhotos,
                    requiresAfterPhotos: _requiresAfterPhotos,
                    servicesLoading: widget.servicesLoading,
                    serviceErrorMsg: _serviceErrorMsg,
                    onServiceChanged: (service, {isNew}) {
                      setState(() {
                        _selectedService = service;
                        if (isNew == true) {
                          _allServices.add(service!);
                        }
                        _serviceErrorMsg = null;
                      });
                    },
                    onRequiresBefore: (requiresBeforePhotos) {
                      setState(() {
                        _requiresBeforePhotos = requiresBeforePhotos;
                      });
                    },
                    onRequiresAfter: (requiresAfterPhotos) {
                      setState(() {
                        _requiresAfterPhotos = requiresAfterPhotos;
                      });
                    },
                  )),
                  SizedBox(height: 32),
                  GTourTarget(id: 'schedule', child: AddVisitWidgetSchedule(
                      key: _startDateKey,
                      technicians: _allTechnicians,
                      selectedPriority: _selectedPriority,
                      selectedTechnician: _selectedTechnician,
                      startDate: _startDate,
                      startTime: _startTime,
                      problem: _problem,
                      notes: _notes,
                      startDateErrorMsg: _startDateErrorMsg,
                      startTimeErrorMsg: _startTimeErrorMsg,
                      techniciansLoading: widget.technicansLoading,
                      onTechnicianChanged: (technician, {isNew}) {
                        setState(() {
                          _selectedTechnician = technician;
                          if (isNew == true) {
                            _allTechnicians.add(technician!);
                          }
                        });
                      },
                      onPriorityChanged: (priority) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                      onStartDatePicked: (startDate) {
                        setState(() {
                          _startDate = startDate;
                          _startDateErrorMsg = null;
                        });
                      },
                      onStartTimeChanged: (startTime) {
                        setState(() {
                          _startTime = startTime;
                          _startTimeErrorMsg = null;
                        });
                      })),
                  SizedBox(height: 90)
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: _selectedTechnician != null
                            ? AppTheme.pending.withValues(alpha: .18)
                            : AppTheme.cardColor.withValues(alpha: .2),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GTourTarget(id: 'actions', child: Row(
                          children: [
                            Expanded(
                                child: GWidgetButton(
                              text: 'Save Draft'.tr,
                              fontSize: AppTheme.textBodyLarge,
                              height: 45,
                              isLoading: _status == VisitStatus.draft &&
                                  widget.addVisitLoading,
                              loadingSize: 16,
                              loadingStrokeWidth: 2.5,
                              loadingColor: AppTheme.iconGrey,
                              colorText: AppTheme.iconGrey,
                              border: Border.all(color: AppTheme.iconGrey),
                              backgroundColor: AppTheme.cardColor,
                              raduis: 10,
                              onPressed: () {
                                _addVisit(VisitStatus.draft);
                              },
                            )),
                            SizedBox(width: 10),
                            Expanded(
                                child: GWidgetButton(
                              text: _selectedTechnician != null
                                  ? 'Assigned'.tr
                                  : 'Schedule'.tr,
                              fontSize: AppTheme.textBodyLarge,
                              raduis: 10,
                              height: 45,
                              isLoading: (_status == VisitStatus.assigned ||
                                      _status == VisitStatus.scheduled) &&
                                  widget.addVisitLoading,
                              loadingSize: 16,
                              loadingStrokeWidth: 2.5,
                              onPressed: () {
                                setState(() {
                                  _clientErrorMsg = null;
                                  _siteErrorMsg = null;
                                  _serviceErrorMsg = null;
                                  _startDateErrorMsg = null;
                                  _startTimeErrorMsg = null;
                                  if (_selectedClient == null) {
                                    _clientErrorMsg =
                                        'This field is required to {0}'.trArgs([_selectedTechnician != null ? 'Assigned'.tr : 'Schedule'.tr]);
                                  }
                                  if (_selectedSite == null) {
                                    _siteErrorMsg =
                                        'This field is required to {0}'.trArgs([_selectedTechnician != null ? 'Assigned'.tr : 'Schedule'.tr]);
                                  }
                                  if (_selectedService == null) {
                                    _serviceErrorMsg =
                                        'This field is required to {0}'.trArgs([_selectedTechnician != null ? 'Assigned'.tr : 'Schedule'.tr]);
                                  }
                                  if (_startDate == null) {
                                    _startDateErrorMsg =
                                        'This field is required to {0}'.trArgs([_selectedTechnician != null ? 'Assigned'.tr : 'Schedule'.tr]);
                                  }
                                  if (_startTime == null) {
                                    _startTimeErrorMsg =
                                        'This field is required to {0}'.trArgs([_selectedTechnician != null ? 'Assigned'.tr : 'Schedule'.tr]);
                                  } else if (_startDateTime != null &&
                                      _startDateTime!
                                          .isBefore(DateTime.now())) {
                                    _startTimeErrorMsg =
                                        'Start time must be in the future'.tr;
                                  }
                                });
                                if (_clientErrorMsg != null ||
                                    _siteErrorMsg != null) {
                                  _moveList(_clientKey);
                                  return;
                                }
                                if (_serviceErrorMsg != null) {
                                  _moveList(_serviceKey);
                                  return;
                                }
                                if (_startDateErrorMsg != null ||
                                    _startTimeErrorMsg != null) {
                                  _moveList(_startDateKey);
                                  return;
                                }
                                _addVisit(_selectedTechnician != null
                                    ? VisitStatus.assigned
                                    : VisitStatus.scheduled);
                              },
                            ))
                          ],
                        )),
                        if (_selectedTechnician != null) ...[
                          SizedBox(height: 6),
                          Text(
                            'Tip: Since you\'ve already chosen a technician, the \'Schedule\' button has updated to \'Assigned\''.tr,
                            style: AppTheme.font(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: AppTheme.textSmall),
                          )
                        ]
                      ],
                    )),
              ),
            )
          ],
        ));
  }
}
