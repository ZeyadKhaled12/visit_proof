import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../visits/data/models/visit_detail_models/visit_history_model.dart';
import 'sheets/visit_detail_widget_comment_sheet.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_action_sheet.dart';
import 'visit_detail_widget_parts.dart';

/// Audit trail of the visit, newest first, with a colored timeline.
class VisitDetailWidgetHistory extends StatefulWidget {
  const VisitDetailWidgetHistory({super.key, required this.history});
  final List<VisitHistoryModel> history;

  @override
  State<VisitDetailWidgetHistory> createState() =>
      _VisitDetailWidgetHistoryState();
}

class _VisitDetailWidgetHistoryState
    extends State<VisitDetailWidgetHistory> {
  static const int _collapsedCount = 5;
  static List<Color> get _palette => [
    AppTheme.primary,
    AppTheme.secondary,
    AppTheme.statOrange,
    AppTheme.statGreen,
    AppTheme.pending,
  ];

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entries = [...widget.history]..sort((a, b) =>
        (b.recordedAt ?? DateTime(0)).compareTo(a.recordedAt ?? DateTime(0)));
    final visible =
        _expanded ? entries : entries.take(_collapsedCount).toList();

    return VisitDetailSection(
      title: 'Activity',
      icon: Icons.history_rounded,
      color: AppTheme.primary,
      actionText: 'Add note',
      actionIcon: Icons.add_comment_rounded,
      onAction: () => VisitDetailWidgetActionSheet.show(
          context, const VisitDetailWidgetCommentSheet()),
      child: entries.isEmpty
          ? const VisitDetailEmpty(
              icon: Icons.history_toggle_off_rounded, text: 'No activity yet')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < visible.length; i++)
                  _HistoryTile(
                    entry: visible[i],
                    color: _palette[i % _palette.length],
                    isLast: i == visible.length - 1,
                  ),
                if (entries.length > _collapsedCount)
                  TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(
                        _expanded ? 'Show less' : 'Show all (${entries.length})',
                        style: AppTheme.font(
                            color: AppTheme.primary,
                            fontSize: AppTheme.textBody,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(
      {required this.entry, required this.color, required this.isLast});
  final VisitHistoryModel entry;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final actor = [entry.actor?.name, entry.actor?.role]
        .where((e) => (e ?? '').isNotEmpty)
        .join(' · ');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: color.withValues(alpha: .25),
                      width: 3,
                      strokeAlign: BorderSide.strokeAlignOutside),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                      width: 2, color: AppTheme.iconLightGrey.withValues(alpha: .5)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.description ?? 'Update',
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textBody,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                      [
                        VisitDetailHelpers.dateTime(entry.recordedAt),
                        if (actor.isNotEmpty) actor,
                      ].join(' · '),
                      style: AppTheme.font(
                          color: AppTheme.textSecondary, fontSize: AppTheme.textCaption)),
                  if ((entry.reason ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('“${entry.reason}”',
                          style: AppTheme.font(
                              color: AppTheme.textDarkHint,
                              fontSize: AppTheme.textSmall,
                              fontStyle: FontStyle.italic,
                              height: 1.4)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
