import 'package:flutter/material.dart';
import 'package:visit_proof/features/visit_detail/presentation/screens/visit_detail_scr.dart';

import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../data/models/visit_detail_models/visit_detail_model.dart';

class VisitsWidgetCard extends StatelessWidget {
  const VisitsWidgetCard({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  Widget build(BuildContext context) {
    final statusSwitch = VisitStatusSwitch(visitStatusEnum: visit.status);
    final prioritySwitch = PrioritySwitch(priorityEnum: visit.priority);
    final paymentSwitch =
        PaymentStatusSwitch(paymentStatusEnum: visit.paymentStatus);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (visit.id == null) return;
          Navigator.pushNamed(context, VisitDetailScr.route,
              arguments: VisitDetailArgu(visitID: visit.id!).toArgu());
        },
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadowColor,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppColors.cardAccent.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            visit.visitNumber ?? '#VISIT-000',
                            style: AppFonts(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.calendar_today_outlined,
                              size: 12, color: AppColors.iconGrey),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(visit.startDate),
                            style: AppFonts(
                              color: AppColors.textDarkHint,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          _buildChip(
                            text: statusSwitch.getText(),
                            color: statusSwitch.getColor(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactInfo(
                              icon: Icons.person_outline,
                              text: visit.client?.name ?? 'no client',
                              textColor: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildCompactInfo(
                              icon: Icons.build_circle_outlined,
                              text: visit.category?.name ?? 'no category',
                              textColor: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildCompactInfo(
                        icon: Icons.engineering_outlined,
                        text: visit.technicianModel?.name ??
                            'no technician assigned',
                        textColor: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactInfo(
                        icon: Icons.location_on_outlined,
                        text:
                            '${visit.site?.city?.name ?? 'Unknown'} - ${visit.site?.addressDetail ?? ''}',
                        textColor: AppColors.textSecondary,
                      ),
                      if (visit.problemDescription != null &&
                          visit.problemDescription!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            visit.problemDescription!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts(
                              color: AppColors.textNotes,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildChip(
                            text: prioritySwitch.getText(),
                            color: prioritySwitch.getColor(),
                            isSmall: true,
                          ),
                          const SizedBox(width: 6),
                          _buildChip(
                            text: paymentSwitch.getText(),
                            color: paymentSwitch.getColor(),
                            isSmall: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildCompactInfo({
    required IconData icon,
    required String text,
    required Color textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String text,
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppFonts(
          color: color,
          fontSize: isSmall ? 9 : 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No Date';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'; // Removed year to save horizontal space
  }
}
