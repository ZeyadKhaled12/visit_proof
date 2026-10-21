import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/technician_status_enum.dart';
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
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: AppFonts(
                            color: AppColors.primary,
                            fontSize: 20,
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
                                  technician.name ?? 'Unknown Technician',
                                  style: AppFonts(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
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
                                      style: AppFonts(
                                        color: statusColor,
                                        fontSize: 11,
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
                              style: AppFonts(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Bottom Row: Phone and Open Jobs
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              children: [
                                const Icon(Icons.phone,
                                    size: 14, color: AppColors.textLightHint),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    technician.phone ?? 'No Phone',
                                    style: AppFonts(
                                      color: AppColors.textDarkHint,
                                      fontSize: 13,
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
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.locationChipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment_ind_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${technician.openJobs ?? 0} Open Jobs',
                      style: AppFonts(
                        color: AppColors.textPrimary,
                        fontSize: 12,
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
