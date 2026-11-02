import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/features/services/domain/usecases/remove_service_uc.dart';
import '../../../../../configs/app_theme.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../data/models/service_model.dart';
import '../../controller/services_bloc.dart';
import '../../screens/add_service_scr.dart';

class ServicesWidgetCard extends StatelessWidget {
  final ServiceModel service;

  const ServicesWidgetCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final hasChecklist =
        service.checkList != null && service.checkList!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10), // Tighter vertical padding
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Ensures it only takes needed height
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side: Service Name & Category Pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.miscellaneous_services,
                              size: 16, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            service.serviceName ?? 'Unnamed Service'.tr,
                            style: AppTheme.font(
                              color: AppTheme.textPrimary,
                              fontSize: AppTheme.textSubtitle,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Category Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2), // Tighter padding
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.category,
                              size: 12, color: AppTheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            service.category?.name?.tr ?? 'No Category'.tr,
                            style: AppTheme.font(
                              color: AppTheme.secondary,
                              fontSize: AppTheme.textCaption,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right Side: Actions & Price Tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () async {
                          final data = await AddServiceScr.show(context,
                              serviceModel: service);
                          if (data is ServiceModel) {
                            context.read<ServicesBloc>().add(
                                GetServicesEvent(noParameters: NoParameters()));
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.edit_rounded,
                              size: 14, color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () async {
                          if (service.id == null) return;
                          final data = await AppToasts.showDeleteConfirmation(
                            title:
                                'Are you sure you want to remove this service? This action cannot be undone.'.tr,
                            headTitle: 'Remove Service?'.tr,
                          );
                          if (data is bool) {
                            if (data) {
                              context.read<ServicesBloc>().add(
                                  RemoveServiceEvent(
                                      removeServiceParameters:
                                          RemoveServiceParameters(
                                              serviceID: service.id!)));
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppTheme.statOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.delete_outline_rounded,
                              size: 14, color: AppTheme.statOrange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price Tag
                  if (service.defaultPrice != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.statGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${App.currency} ${service.defaultPrice!.toStringAsFixed(2)}',
                        style: AppTheme.font(
                          color: AppTheme.statGreen,
                          fontSize: AppTheme.textSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Checklist Section
          if (hasChecklist) ...[
            const SizedBox(height: 8),
            Divider(color: AppTheme.locationChipBg, thickness: 1, height: 1),
            const SizedBox(height: 8),

            // Checklist Items (Removed the "Service Checklist:" title to save space)
            ...service.checkList!.map((item) => Padding(
                  padding: const EdgeInsets.only(
                      bottom: 4), // Tighter bottom padding
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1.5),
                        child: Icon(Icons.check_circle,
                            size: 12, color: AppTheme.primary), // Smaller Icon
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTheme.font(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.textCaption, // Slightly smaller text
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ]
        ],
      ),
    );
  }
}
