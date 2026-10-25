import 'package:flutter/material.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_add_btn.dart';

import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../core/utils/general_models/g_model_catg.dart';
import '../../../../core/utils/general_widgets/g_widget_card_title.dart';
import '../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../core/utils/general_widgets/g_widget_switcher.dart';
import '../../../services/data/models/service_model.dart';

final List<ServiceModel> dummyServices = [
  ServiceModel(
    id: 'srv_001',
    category: const GModelCatg(
      id: 'cat_hvac',
      name: 'HVAC',
      description: 'Heating, Ventilation, and Air Conditioning services.',
    ),
    serviceName: 'AC Routine Maintenance',
    defaultPrice: 450.0,
    duration: 60, // 60 minutes
    checkList: [
      'Clean or replace air filters',
      'Inspect condenser coils',
      'Check refrigerant levels',
      'Test thermostat calibration'
    ],
  ),
  ServiceModel(
    id: 'srv_002',
    category: const GModelCatg(
      id: 'cat_hvac',
      name: 'HVAC',
      description: 'Heating, Ventilation, and Air Conditioning services.',
    ),
    serviceName: 'AC Compressor Repair',
    defaultPrice: 1200.0,
    duration: 120, // 2 hours
    checkList: [
      'Isolate power supply',
      'Remove faulty compressor',
      'Install new compressor unit',
      'Vacuum and recharge system',
      'Test for leaks'
    ],
  ),
  ServiceModel(
    id: 'srv_003',
    category: const GModelCatg(
      id: 'cat_elec',
      name: 'Electrical',
      description: 'Electrical inspection, repair, and installation.',
    ),
    serviceName: 'Electrical Panel Inspection',
    defaultPrice: 300.0,
    duration: 45,
    checkList: [
      'Check for scorched wires',
      'Tighten electrical connections',
      'Measure voltage and amperage',
      'Verify grounding'
    ],
  ),
  ServiceModel(
    id: 'srv_004',
    category: const GModelCatg(
      id: 'cat_plumb',
      name: 'Plumbing',
      description: 'Piping, fixtures, and water systems.',
    ),
    serviceName: 'Water Heater Installation',
    defaultPrice: 850.0,
    duration: 180,
    checkList: [
      'Drain existing water heater',
      'Disconnect plumbing and electrical/gas',
      'Position new unit safely',
      'Connect water lines and test pressure'
    ],
  ),
  ServiceModel(
    id: 'srv_005',
    category: const GModelCatg(
      id: 'cat_clean',
      name: 'Cleaning',
      description: 'Residential and commercial cleaning services.',
    ),
    serviceName: 'Deep Office Cleaning',
    defaultPrice: 600.0,
    duration: 240,
    checkList: null, // Testing a null checklist
  ),
  ServiceModel(
    id: 'srv_006',
    category: null, // Testing a null category
    serviceName: 'General Site Consultation',
    defaultPrice: 0.0, // Free consultation
    duration: 30,
    checkList: [
      'Client interview',
      'Site walk-through',
      'Draft preliminary estimate'
    ],
  ),
];

class AddVisitWidgetService extends StatelessWidget {
  const AddVisitWidgetService(
      {super.key,
      this.selectedService,
      required this.requiresBeforePhotos,
      required this.requiresAfterPhotos,
      required this.onServiceChanged,
      required this.onRequiresBefore,
      required this.onRequiresAfter});
  final ServiceModel? selectedService;
  final bool requiresBeforePhotos;
  final bool requiresAfterPhotos;
  final Function(ServiceModel? service) onServiceChanged;
  final Function(bool requiresBeforePhotos) onRequiresBefore;
  final Function(bool requiresAfterPhotos) onRequiresAfter;
  @override
  Widget build(BuildContext context) {
    return GWidgetCardTitle(
        icon: Icons.build_rounded,
        title: 'Service',
        child: Column(
          children: [
            GWidgetDropDown<ServiceModel>(
              labelText: 'Service',
              enableSearch: true,
              value: selectedService,
              onChanged: onServiceChanged,
              items: dummyServices.map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.serviceName ?? '',
                          style: AppFonts(fontWeight: FontWeight.w500)),
                      Text(service.category?.name ?? '',
                          style: AppFonts(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                              fontSize: 11))
                    ],
                  ),
                );
              }).toList(),
              searchHintText: 'Search for client',
            ),
            SizedBox(height: 10),
            GWidgetAddBtn(text: 'Add New Service', onTap: () {}),
            SizedBox(height: 16),
            if (selectedService != null)
              _ServiceSummaryCard(service: selectedService!),
            SizedBox(height: 16),
            GWidgetSwitcher(
                title: 'Require Before-Work Photos',
                value: requiresBeforePhotos,
                onChanged: onRequiresBefore,
                subtitle: 'Technician supplies proof during the visit'),
            GWidgetSwitcher(
                title: 'Require After-Work Photos',
                value: requiresAfterPhotos,
                onChanged: onRequiresAfter,
                subtitle: 'Technician supplies proof during the visit'),
          ],
        ));
  }
}

class _ServiceSummaryCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceSummaryCard({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    // Safely calculate the number of checklist items
    final bool hasChecklist =
        service.checkList != null && service.checkList!.isNotEmpty;
    final int taskCount = hasChecklist ? service.checkList!.length : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.iconLightGrey.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Category Badge & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service.category?.name ?? 'Uncategorized',
                  style: AppFonts(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Price (Only shows if defaultPrice is not null and > 0)
              if (service.defaultPrice != null && service.defaultPrice! > 0)
                Text(
                  '${service.defaultPrice!.toStringAsFixed(2)} EGP', // Change currency as needed
                  style: AppFonts(
                    color: AppColors.whatsappGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Service Name
          Text(
            service.serviceName ?? 'Unnamed Service',
            style: AppFonts(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          // Checklist Section
          if (hasChecklist) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.locationChipBg, // Soft grey background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  service.checkList!.length,
                  (index) {
                    final task = service.checkList![index];
                    final isLast = index == service.checkList!.length - 1;

                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task,
                              style: AppFonts(
                                color: AppColors.textDarkHint,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.schedule_rounded,
                text: '${service.duration ?? 0} Min',
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                icon: Icons.checklist_rtl_rounded,
                text: '$taskCount Task${taskCount == 1 ? '' : 's'}',
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  'Update',
                  style: AppFonts(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.iconGrey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppFonts(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
