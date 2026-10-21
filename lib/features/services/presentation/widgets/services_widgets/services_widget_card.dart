import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/features/services/domain/usecases/remove_service_uc.dart';
import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
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
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadowColor,
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
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.miscellaneous_services,
                              size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            service.serviceName ?? 'Unnamed Service',
                            style: AppFonts(
                              color: AppColors.textPrimary,
                              fontSize: 15,
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
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.category,
                              size: 12, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            service.category?.name ?? 'No Category',
                            style: AppFonts(
                              color: AppColors.secondary,
                              fontSize: 11,
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
                          if (data is bool) {
                            if (data) {
                              context.read<ServicesBloc>().add(GetServicesEvent(
                                  noParameters: NoParameters()));
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 14, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () async {
                          if (service.id == null) return;
                          final data = await AppToasts.showDeleteConfirmation(
                            title:
                                'Are you sure you want to remove this service? This action cannot be undone.',
                            headTitle: 'Remove Service?',
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
                            color: AppColors.statOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              size: 14, color: AppColors.statOrange),
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
                        color: AppColors.statGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${App.currency} ${service.defaultPrice!.toStringAsFixed(2)}',
                        style: AppFonts(
                          color: AppColors.statGreen,
                          fontSize: 12,
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
            Divider(color: AppColors.locationChipBg, thickness: 1, height: 1),
            const SizedBox(height: 8),

            // Checklist Items (Removed the "Service Checklist:" title to save space)
            ...service.checkList!.map((item) => Padding(
                  padding: const EdgeInsets.only(
                      bottom: 4), // Tighter bottom padding
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1.5),
                        child: Icon(Icons.check_circle,
                            size: 12, color: AppColors.primary), // Smaller Icon
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item,
                          style: AppFonts(
                            color: AppColors.textSecondary,
                            fontSize: 11, // Slightly smaller text
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
