import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'dispatch_widget_visit_card.dart';

/// Bottom tray of visits waiting for a technician. Long-press a card and
/// drop it on a technician above. Collapsible to free space on short screens.
class DispatchWidgetUnassignedTray extends StatefulWidget {
  const DispatchWidgetUnassignedTray(
      {super.key, required this.visits, required this.day});
  final List<VisitDetailModel> visits;
  final DateTime day;

  @override
  State<DispatchWidgetUnassignedTray> createState() =>
      _DispatchWidgetUnassignedTrayState();
}

class _DispatchWidgetUnassignedTrayState
    extends State<DispatchWidgetUnassignedTray> {
  /// Below this height the tray starts collapsed to leave room for the board.
  static const double _tallScreen = 700;
  static const double _cardWidth = 230;

  bool? _expanded;

  @override
  Widget build(BuildContext context) {
    final expanded =
        _expanded ?? MediaQuery.sizeOf(context).height >= _tallScreen;
    final visits = widget.visits;

    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.iconLightGrey)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !expanded),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 8, 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.pending.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('${visits.length}',
                          style: AppTheme.font(
                              color: AppTheme.pending,
                              fontSize: AppTheme.textSmall,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Waiting for a technician'.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.font(
                                  color: AppTheme.textPrimary,
                                  fontSize: AppTheme.textBodyLarge,
                                  fontWeight: FontWeight.w800)),
                          if (expanded)
                            Text(
                                visits.isEmpty
                                    ? 'All visits have a technician 🎉'.tr
                                    : 'Long-press a card and drop it on a technician'.tr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.font(
                                    color: AppTheme.textSecondary,
                                    fontSize: AppTheme.textCaption)),
                        ],
                      ),
                    ),
                    Icon(
                        expanded
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                        color: AppTheme.iconGrey),
                  ],
                ),
              ),
            ),
            if (expanded && visits.isNotEmpty) ...[
              const SizedBox(height: 6),
              // Horizontal scroll without a fixed height, so the cards keep
              // their natural height at any text size.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < visits.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      DispatchWidgetVisitCard(
                        visit: visits[i],
                        day: widget.day,
                        width: _cardWidth,
                        draggable: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
