import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_client_model.dart';
import 'package:visit_proof/features/visits/presentation/widgets/add_visit_widget_client.dart';
import 'package:visit_proof/features/visits/presentation/widgets/add_visit_widget_schedule.dart';
import 'package:visit_proof/features/visits/presentation/widgets/add_visit_widget_service.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../../../core/utils/general_widgets/g_widget_navi_body.dart';

class AddVisitScr extends StatefulWidget {
  const AddVisitScr({super.key});

  @override
  State<AddVisitScr> createState() => _AddVisitScrState();
}

class _AddVisitScrState extends State<AddVisitScr> {
  VisitClientModel? _selectedClient;
  GModelSite? _selectedSite;
  ServiceModel? _selectedService;
  Priority? _selectedPriority;
  TechnicianModel? _selectedTechnician;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  bool _requiresBeforePhotos = false;
  bool _requiresAfterPhotos = false;

  @override
  Widget build(BuildContext context) {
    return GWidgetNaviBody(
        title: 'Add Visit',
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  AddVisitWidgetClient(
                    selectedClient: _selectedClient,
                    selectedSite: _selectedSite,
                    onClientChanged: (client) {
                      if (client?.id == _selectedClient?.id) return;
                      setState(() {
                        _selectedClient = client;
                        _selectedSite = null;
                      });
                    },
                    onSiteChanged: (site) {
                      setState(() {
                        _selectedSite = site;
                      });
                    },
                  ),
                  SizedBox(height: 32),
                  AddVisitWidgetService(
                    selectedService: _selectedService,
                    requiresBeforePhotos: _requiresBeforePhotos,
                    requiresAfterPhotos: _requiresAfterPhotos,
                    onServiceChanged: (service) {
                      setState(() {
                        _selectedService = service;
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
                  ),
                  SizedBox(height: 32),
                  AddVisitWidgetSchedule(
                      selectedPriority: _selectedPriority,
                      selectedTechnician: _selectedTechnician,
                      startDate: _startDate,
                      startTime: _startTime,
                      onTechnicianChanged: (technician) {
                        setState(() {
                          _selectedTechnician = technician;
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
                        });
                      },
                      onStartTimeChanged: (startTime) {
                        setState(() {
                          _startTime = startTime;
                        });
                      }),
                  SizedBox(height: 90)
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 5, sigmaY: 5), // Adjust blur intensity
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: AppColors.cardColor.withValues(alpha: .2),
                      boxShadow: [BoxShadow(color: AppColors.shadowColor)],
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25))),
                  child: Row(
                    children: [
                      Expanded(
                          child: GWidgetButton(
                        text: 'Save Draft',
                        fontSize: 14,
                        colorText: AppColors.iconGrey,
                        border: Border.all(color: AppColors.iconGrey),
                        backgroundColor: AppColors.cardColor,
                        raduis: 10,
                        onPressed: () {},
                      )),
                      SizedBox(width: 10),
                      Expanded(
                          child: GWidgetButton(
                        text: 'Schedule',
                        fontSize: 14,
                        raduis: 10,
                        onPressed: () {},
                      ))
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
