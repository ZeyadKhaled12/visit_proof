import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/core/utils/enums/technician_status_enum.dart';

import '../../../../../app/app.dart';
import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_launch.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../data/models/technician_detail_model.dart';

class TechDetailWidgetHeader extends StatelessWidget {
  const TechDetailWidgetHeader(
      {super.key, required this.technicianDetailModel});
  final TechnicianDetailModel technicianDetailModel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 90,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.iconLightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppTheme.primary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        technicianDetailModel.name
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'T',
                        style: AppTheme.font(
                          color: AppTheme.primary,
                          fontSize: AppTheme.textDisplay,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technicianDetailModel.name ?? 'Unknown Technician'.tr,
                          style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textTitleLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Replaced Location with Status Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: TechnicianStatusSwitch(
                                    technicianStatusEnum:
                                        technicianDetailModel.status)
                                .getColor()
                                .withValues(alpha: .68),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            TechnicianStatusSwitch(
                                    technicianStatusEnum:
                                        technicianDetailModel.status)
                                .getText()
                                .toUpperCase(),
                            style: AppTheme.font(
                                color: AppTheme.cardColor,
                                fontSize: AppTheme.textSmall,
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ContactRowWidget(
                      icon: Icons.phone,
                      text: technicianDetailModel.phone ?? 'No Phone'.tr,
                      iconColor: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GWidgetButton(
                    height: 34,
                    paddingLeftRight: 5,
                    raduis: 10,
                    backgroundColor: AppTheme.primary.withValues(alpha: .8),
                    paddingTopBottom: 0,
                    onPressed: () async {
                      if (technicianDetailModel.phone == null) return;
                      await GFunLaunch.makePhoneCall(
                          technicianDetailModel.phone!);
                    },
                    widget: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: AppTheme.cardColor,
                        ),
                        Icon(Icons.navigate_next_outlined,
                            color: AppTheme.cardColor, size: 14)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ContactRowWidget(
                icon: Icons.email,
                text: technicianDetailModel.email ?? 'No Email'.tr,
                iconColor: AppTheme.statOrange,
              ),
              const SizedBox(height: 16),
              Divider(color: AppTheme.locationChipBg, thickness: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _StatItemWidget(
                        title: 'Open Jobs'.tr,
                        value:
                            technicianDetailModel.openJobs?.toString() ?? '0',
                        color: AppTheme.pending),
                  ),
                  Container(
                      height: 30, width: 1, color: AppTheme.locationChipBg),
                  Expanded(
                    child: _StatItemWidget(
                        title: 'Completed'.tr,
                        value:
                            technicianDetailModel.completedJobs?.toString() ??
                                '0',
                        color: AppTheme.primary),
                  ),
                  Container(
                      height: 30, width: 1, color: AppTheme.locationChipBg),
                  Expanded(
                    flex: 2,
                    child: _StatItemWidget(
                        title: 'Total Paid'.tr,
                        value:
                            '${App.currency} ${technicianDetailModel.completedPaid ?? 0}',
                        color: AppTheme.statGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// NOTE: If you are placing this in the exact same file as ClientDetailWidgetHeader,
// you can delete these two private classes below to avoid duplication errors.
// If it's in a separate file, keep them.

class _ContactRowWidget extends StatelessWidget {
  const _ContactRowWidget({
    required this.icon,
    required this.text,
    required this.iconColor,
  });
  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  color: iconColor, fontSize: AppTheme.textBody, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItemWidget extends StatelessWidget {
  const _StatItemWidget(
      {required this.title, required this.value, required this.color});
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style:
              AppTheme.font(color: color, fontSize: AppTheme.textHeadline, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: AppTheme.font(color: AppTheme.textSecondary, fontSize: AppTheme.textSmall),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
