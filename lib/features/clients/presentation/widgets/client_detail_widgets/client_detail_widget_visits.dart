import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../app/app.dart';
import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../visit_detail/presentation/screens/visit_detail_scr.dart';
import '../../../data/models/client_detail_model/client_visit_model.dart';

/// Visit history list, shared by the client and technician detail screens.
class ClientDetailWidgetVisits extends StatelessWidget {
  const ClientDetailWidgetVisits(
      {super.key, required this.visits, required this.onVisitClosed});
  final List<ClientVisitModel> visits;

  /// Called after a visit screen closes, so the history can reload.
  final VoidCallback onVisitClosed;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.locationChipBg),
          ),
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded,
                  size: 32, color: AppTheme.iconLightGrey),
              const SizedBox(height: 8),
              Text('No visits recorded yet',
                  style: AppTheme.font(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.textBodyLarge,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) => _VisitCard(
          visit: visits[index], onVisitClosed: onVisitClosed),
      childCount: visits.length,
    ));
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit, required this.onVisitClosed});
  final ClientVisitModel visit;
  final VoidCallback onVisitClosed;

  Future<void> _open(BuildContext context) async {
    await Navigator.pushNamed(context, VisitDetailScr.route,
        arguments: VisitDetailArgu(visitID: visit.id!).toArgu());
    onVisitClosed();
  }

  @override
  Widget build(BuildContext context) {
    final status = VisitStatusSwitch(visitStatusEnum: visit.status);
    final payment = PaymentStatusSwitch(paymentStatusEnum: visit.paymentStatus);
    final accent = status.getColor();

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: visit.id == null ? null : () => _open(context),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accent, width: 5)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(visit.visitNumber ?? 'Visit',
                              style: AppTheme.font(
                                  color: AppTheme.textPrimary,
                                  fontSize: AppTheme.textBody,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(width: 8),
                          Icon(Icons.calendar_today_rounded,
                              size: 12, color: AppTheme.iconGrey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                                visit.visitDate == null
                                    ? 'No date'
                                    : DateFormat('dd MMM yyyy · hh:mm a')
                                        .format(visit.visitDate!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.font(
                                    color: AppTheme.textSecondary,
                                    fontSize: AppTheme.textCaption,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(visit.serviceName ?? 'No service',
                                style: AppTheme.font(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppTheme.textSubtitle,
                                    fontWeight: FontWeight.w700)),
                          ),
                          if (visit.totalAmount != null)
                            Text(
                                '${visit.totalAmount!.toStringAsFixed(2)} ${App.currency}',
                                style: AppTheme.font(
                                    color: AppTheme.statGreen,
                                    fontSize: AppTheme.textBodyLarge,
                                    fontWeight: FontWeight.w800)),
                        ],
                      ),
                      if ((visit.problem ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(visit.problem!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.font(
                                color: AppTheme.textDarkHint, fontSize: AppTheme.textSmall)),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.engineering_rounded,
                              size: 15, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                                visit.technicianName ?? 'No technician',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.font(
                                    color: AppTheme.textSecondary,
                                    fontSize: AppTheme.textSmall,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Pill(text: status.getText(), color: accent),
                          _Pill(
                              text: payment.getText(),
                              color: payment.getColor()),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    color: AppTheme.primary.withValues(alpha: .5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text,
          style: AppTheme.font(
              color: color, fontSize: AppTheme.textCaption, fontWeight: FontWeight.w800)),
    );
  }
}
