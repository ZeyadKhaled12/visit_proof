import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';

class VisitDetailPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const VisitDetailPanel({super.key, required this.title, required this.icon, required this.child});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: AppColors.cardShadowColor, blurRadius: 15, offset: const Offset(0, 5))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(11)),
        child: Icon(icon, color: AppColors.primary, size: 18)), const SizedBox(width: 10),
        Expanded(child: Text(title, style: AppFonts(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w800)))]),
      const SizedBox(height: 12), child,
    ]),
  );
}

class VisitDetailLine extends StatelessWidget {
  final String label, value;
  const VisitDetailLine({super.key, required this.label, required this.value});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 2, child: Text(label, style: AppFonts(color: AppColors.textSecondary, fontSize: 12))),
      Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, style: AppFonts(
        color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700))),
    ]),
  );
}

class VisitStatusBadge extends StatelessWidget {
  final VisitStatus? status;
  final bool onDark;
  const VisitStatusBadge({super.key, this.status, this.onDark = false});
  @override Widget build(BuildContext context) {
    final color = VisitStatusSwitch(visitStatusEnum: status).getColor();
    final label = VisitStatusSwitch(visitStatusEnum: status).getText();
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: onDark ? AppColors.surfaceWhite : color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
      child: Text(label.toUpperCase(), style: AppFonts(color: onDark ? AppColors.textPrimary : color, fontSize: 11, fontWeight: FontWeight.w800)));
  }
}

class VisitHistoryPanel extends StatelessWidget {
  final VisitDetailModel visit;
  const VisitHistoryPanel({super.key, required this.visit});
  @override Widget build(BuildContext context) {
    final items = [...?visit.history]..sort((a,b) => (b.recordedAt ?? DateTime(1970)).compareTo(a.recordedAt ?? DateTime(1970)));
    return VisitDetailPanel(title: 'Activity & audit history', icon: Icons.history_rounded,
      child: items.isEmpty
      ? Text('No activity recorded yet.', style: AppFonts(color: AppColors.textSecondary))
      : Column(children: items.map((h) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(margin: const EdgeInsets.only(top: 3), height: 9, width: 9,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h.description ?? 'Visit activity', style: AppFonts(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            if ((h.reason ?? '').trim().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4),
              child: Text('Reason: ${h.reason}', style: AppFonts(color: AppColors.statOrange, fontSize: 11))),
            const SizedBox(height: 4),
            Text('${h.actor?.name ?? h.actor?.role ?? 'Admin'} · ${h.recordedAt?.toLocal().toString().split('.').first ?? '—'}',
              style: AppFonts(color: AppColors.textSecondary, fontSize: 10)),
          ])),
        ]),
      )).toList()),
    );
  }
}
