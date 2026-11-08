import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_add_btn.dart';

import '../../../../app/app.dart';
import '../../../../configs/app_theme.dart';
import '../../../../core/utils/general_widgets/g_widget_card_title.dart';
import '../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../core/utils/general_widgets/g_widget_switcher.dart';
import '../../../services/data/models/service_model.dart';
import '../../../services/presentation/screens/add_service_scr.dart';

class AddVisitWidgetService extends StatelessWidget {
  const AddVisitWidgetService(
      {super.key,
      this.selectedService,
      required this.requiresBeforePhotos,
      required this.requiresAfterPhotos,
      required this.onServiceChanged,
      required this.onRequiresBefore,
      required this.onRequiresAfter,
      required this.services,
      this.serviceErrorMsg,
      required this.servicesLoading});
  final List<ServiceModel> services;
  final ServiceModel? selectedService;
  final bool requiresBeforePhotos;
  final bool requiresAfterPhotos;
  final bool servicesLoading;
  final String? serviceErrorMsg;
  final Function(ServiceModel? service, {bool? isNew}) onServiceChanged;
  final Function(bool requiresBeforePhotos) onRequiresBefore;
  final Function(bool requiresAfterPhotos) onRequiresAfter;
  @override
  Widget build(BuildContext context) {
    return GWidgetCardTitle(
        icon: Icons.build_rounded,
        title: 'Service'.tr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GWidgetDropDown<ServiceModel>(
              labelText: 'Service'.tr,
              enableSearch: true,
              loading: servicesLoading,
              errorMsg: serviceErrorMsg,
              value: selectedService,
              onChanged: onServiceChanged,
              items: services.map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.serviceName ?? '',
                          style: AppTheme.font(fontWeight: FontWeight.w500)),
                      Text((service.category?.name ?? '').tr,
                          style: AppTheme.font(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.iconGrey,
                              fontSize: AppTheme.textCaption))
                    ],
                  ),
                );
              }).toList(),
              searchHintText: 'Search for client'.tr,
            ),
            SizedBox(height: 10),
            GWidgetAddBtn(
                text: 'Add New Service'.tr,
                onTap: () async {
                  final data = await AddServiceScr.show(context);
                  if (data is ServiceModel) {
                    onServiceChanged(data, isNew: true);
                  }
                }),
            SizedBox(height: 16),
            if (selectedService != null)
              _ServiceSummaryCard(
                service: selectedService!,
                onUpdate: () async {
                  final data = await AddServiceScr.show(context,
                      blockSetLocal: true, serviceModel: selectedService);
                  if (data is ServiceModel) {
                    onServiceChanged(data);
                  }
                },
              ),
            SizedBox(height: 16),
            GWidgetSwitcher(
                title: 'Require Before-Work Photos'.tr,
                value: requiresBeforePhotos,
                onChanged: onRequiresBefore,
                subtitle: 'Technician supplies proof during the visit'.tr),
            GWidgetSwitcher(
                title: 'Require After-Work Photos'.tr,
                value: requiresAfterPhotos,
                onChanged: onRequiresAfter,
                subtitle: 'Technician supplies proof during the visit'.tr),
          ],
        ));
  }
}

class _ServiceSummaryCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onUpdate;

  const _ServiceSummaryCard({required this.service, required this.onUpdate});

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
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.iconLightGrey,
        ),
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
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service.category?.name?.tr ?? 'Uncategorized'.tr,
                  style: AppTheme.font(
                    color: AppTheme.primary,
                    fontSize: AppTheme.textSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Price (Only shows if defaultPrice is not null and > 0)
              if (service.defaultPrice != null && service.defaultPrice! > 0)
                Text(
                  '${service.defaultPrice!.toStringAsFixed(2)} ${App.currency}', // Change currency as needed
                  style: AppTheme.font(
                    color: AppTheme.whatsappGreen,
                    fontSize: AppTheme.textSubtitle,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Service Name
          Text(
            service.serviceName ?? 'Unnamed Service'.tr,
            style: AppTheme.font(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.textTitle,
              fontWeight: FontWeight.w700,
            ),
          ),

          // Checklist Section
          if (hasChecklist) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.locationChipBg, // Soft grey background
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
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task,
                              style: AppTheme.font(
                                color: AppTheme.textDarkHint,
                                fontSize: AppTheme.textBody,
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
                text: '{0} Min'.trArgs([service.duration ?? 0]),
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                icon: Icons.checklist_rtl_rounded,
                text: '{0} Task{1}'.trArgs([taskCount, taskCount == 1 ? '' : 's']),
              ),
              const Spacer(),
              TextButton(
                onPressed: onUpdate,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppTheme.primary.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  'Update'.tr,
                  style: AppTheme.font(
                    fontSize: AppTheme.textBody,
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
          color: AppTheme.iconGrey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.font(
            color: AppTheme.textSecondary,
            fontSize: AppTheme.textBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
