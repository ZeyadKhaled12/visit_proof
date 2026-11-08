import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/app_role_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_location.dart';
import '../../../../core/utils/general_widgets/g_widget_location_view_scr.dart';
import '../../../visits/data/models/visit_detail_models/visit_history_model.dart';
import 'sheets/visit_detail_widget_comment_sheet.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_action_sheet.dart';
import 'visit_detail_widget_parts.dart';

/// Audit trail of the visit, newest first, with a colored timeline.
/// Technician entries show where the technician was at that moment.
class VisitDetailWidgetHistory extends StatefulWidget {
  const VisitDetailWidgetHistory(
      {super.key, required this.history, this.canAddNote = true});
  final List<VisitHistoryModel> history;
  final bool canAddNote;

  @override
  State<VisitDetailWidgetHistory> createState() =>
      _VisitDetailWidgetHistoryState();
}

class _VisitDetailWidgetHistoryState
    extends State<VisitDetailWidgetHistory> {
  static const int _collapsedCount = 5;
  static List<Color> get _palette => [
    AppTheme.primary,
    AppTheme.primary,
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
      title: 'Activity'.tr,
      icon: Icons.history_rounded,
      color: AppTheme.primary,
      actionText: widget.canAddNote ? 'Add note'.tr : null,
      actionIcon: widget.canAddNote ? Icons.add_comment_rounded : null,
      onAction: widget.canAddNote
          ? () => VisitDetailWidgetActionSheet.show(
              context, const VisitDetailWidgetCommentSheet())
          : null,
      child: entries.isEmpty
          ? VisitDetailEmpty(
              icon: Icons.history_toggle_off_rounded, text: 'No activity yet'.tr)
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
                        _expanded ? 'Show less'.tr : 'Show all ({0})'.trArgs([entries.length]),
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
    final actor = [entry.actor?.name, _roleText(entry.actor?.role)]
        .where((e) => (e ?? '').isNotEmpty)
        .join(' · ');
    final location = entry.location;

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
                  Text(entry.description?.tr ?? 'Update'.tr,
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
                  if (location != null && location.isValid) ...[
                    const SizedBox(height: 6),
                    _LocationChip(
                      color: color,
                      distance: entry.distanceFromSite,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GWidgetLocationViewScr(
                              latitude: location.latitude!,
                              longitude: location.longitude!),
                        ),
                      ),
                    ),
                  ],
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

/// Stored roles are 'admin' / 'technician' (older entries may hold a label).
String? _roleText(String? role) {
  switch (role?.toLowerCase()) {
    case 'admin':
      return AppRoleSwitch(appRoleEnum: AppRole.admin).getText();
    case 'technician':
      return AppRoleSwitch(appRoleEnum: AppRole.technician).getText();
    default:
      return role;
  }
}

/// "Location · 35 m from site": opens the map at the recorded position.
class _LocationChip extends StatelessWidget {
  const _LocationChip(
      {required this.color, required this.distance, required this.onTap});
  final Color color;
  final double? distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                      distance == null
                          ? 'Technician location · site has no map pin'.tr
                          : 'Technician location · {0} from site'
                              .trArgs([GFunLocation.distanceText(distance!)]),
                      style: AppTheme.font(
                          color: color,
                          fontSize: AppTheme.textCaption,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
