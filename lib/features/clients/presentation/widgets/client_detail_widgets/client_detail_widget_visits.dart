import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../app/app.dart';
import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../../core/utils/enums/visit_status_enum.dart';
import '../../../data/models/client_detail_model/client_visit_model.dart';

class ClientDetailWidgetVisits extends StatelessWidget {
  const ClientDetailWidgetVisits({super.key, required this.visits});
  final List<ClientVisitModel> visits;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.locationChipBg),
          ),
          child: Center(
            child: Text(
              'No visits recorded.',
              style: AppFonts(color: AppColors.textLightHint, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        final visit = visits[index];
        final vStatus = VisitStatusSwitch(visitStatusEnum: visit.status);
        final pStatus =
            PaymentStatusSwitch(paymentStatusEnum: visit.paymentStatus);

        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.locationChipBg, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.locationChipBg.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      visit.visitCode ?? '#VST-UNKNOWN',
                      style: AppFonts(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          visit.visitDate != null
                              ? DateFormat('MMM dd, yyyy')
                                  .format(visit.visitDate!)
                              : 'Unknown Date',
                          style: AppFonts(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Ticket Body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name & Total Paid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            visit.serviceName ?? 'General Service',
                            style: AppFonts(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (visit.totalAmount != null)
                          Text(
                            '${App.currency} ${visit.totalAmount!.toStringAsFixed(2)}',
                            style: AppFonts(
                                color: AppColors.statGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),

                    // Problem / Issue
                    if (visit.problem != null && visit.problem!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: AppFonts(
                                  color: AppColors.textPrimary, fontSize: 14)),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Issue: ',
                                  style: AppFonts(
                                      color: AppColors.textDarkHint,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                Flexible(
                                  child: Text(
                                    '${visit.problem}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts(
                                        color: AppColors.textDarkHint,
                                        fontSize: 12.5),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Work Performed
                    if (visit.workPerformed != null &&
                        visit.workPerformed!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: AppFonts(
                                  color: AppColors.textPrimary, fontSize: 14)),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Work: ',
                                  style: AppFonts(
                                      color: AppColors.textDarkHint,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                Flexible(
                                  child: Text(
                                    '${visit.workPerformed}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts(
                                        color: AppColors.textDarkHint,
                                        fontSize: 12.5),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),
                    // Technician Name
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.primary,
                          child:
                              Icon(Icons.person, size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          visit.technicianName ?? 'Unassigned Technician',
                          style: AppFonts(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBadge(vStatus.getText(), vStatus.getColor()),
                        _buildBadge(pStatus.getText(), pStatus.getColor(),
                            isOutline: true),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
      childCount: visits.length,
    ));
  }
}



Widget _buildBadge(String text, Color color, {bool isOutline = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isOutline ? Colors.transparent : color.withValues(alpha: 0.15),
      border: isOutline ? Border.all(color: color, width: 1.2) : null,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: AppFonts(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
