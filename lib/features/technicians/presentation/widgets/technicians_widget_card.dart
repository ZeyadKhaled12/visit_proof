import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/app_theme.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/technician_status_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_launch.dart';
import '../../data/models/technician_model.dart';
import '../controller/tech_bloc.dart';
import '../screens/technician_detail_scr.dart';

class TechnicianWidgetCard extends StatelessWidget {
  final TechnicianModel technician;

  const TechnicianWidgetCard({super.key, required this.technician});

  @override
  Widget build(BuildContext context) {
    // Determine status color and text using your switch class
    final statusSwitch =
        TechnicianStatusSwitch(technicianStatusEnum: technician.status);
    final statusColor = statusSwitch.getColor();
    final statusText = statusSwitch.getText();

    // Get first letter for avatar
    final String initial =
        technician.name != null && technician.name!.isNotEmpty
            ? technician.name!.substring(0, 1).toUpperCase()
            : 'T';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (technician.id != null) {
            final data = await Navigator.pushNamed(
                context, TechnicianDetailScr.route,
                arguments:
                    TechnicianDetailArgu(techID: technician.id!).toArgu());
            if (data is bool) {
              if (data) {
                context
                    .read<TechBloc>()
                    .add(GetTechniciansEvent(noParameters: NoParameters()));
              }
            }
          }
        },
        highlightColor: AppTheme.primary.withValues(alpha: 0.05),
        splashColor: AppTheme.primary.withValues(alpha: 0.1),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: AppTheme.font(
                            color: AppTheme.primary,
                            fontSize: AppTheme.textHeadline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Details Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Name and Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  technician.name ?? 'Unknown Technician'.tr,
                                  style: AppTheme.font(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppTheme.textTitle,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                        radius: 3,
                                        backgroundColor: statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusText,
                                      style: AppTheme.font(
                                        color: statusColor,
                                        fontSize: AppTheme.textCaption,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Category
                          if (technician.categories?.isNotEmpty ?? false)
                            Text(
                              technician.categories
                                      ?.map((e) => e.name ?? '')
                                      .join(', ') ??
                                  '',
                              style: AppTheme.font(
                                color: AppTheme.textSecondary,
                                fontSize: AppTheme.textCaption,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Bottom Row: Phone and Open Jobs
                          InkWell(
                            onTap: technician.phone == null
                                ? null
                                : () =>
                                    GFunLaunch.makePhoneCall(technician.phone!),
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              children: [
                                Icon(Icons.phone,
                                    size: 14, color: AppTheme.textLightHint),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    technician.phone ?? 'No Phone'.tr,
                                    style: AppTheme.font(
                                      color: AppTheme.textDarkHint,
                                      fontSize: AppTheme.textBody,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons (Optional Edit/Delete at the far right)
                    const SizedBox(width: 8),
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: AppTheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.locationChipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_ind_rounded,
                        size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '{0} Open Jobs'.trArgs([technician.openJobs ?? 0]),
                      style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
