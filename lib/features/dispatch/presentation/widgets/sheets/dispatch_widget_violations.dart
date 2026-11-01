import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../domain/rules/dispatch_rules.dart';

/// Rule results: red blocks the action, amber needs a reason, green is clear.
class DispatchWidgetViolations extends StatelessWidget {
  const DispatchWidgetViolations({super.key, required this.violations});
  final List<DispatchViolation> violations;

  @override
  Widget build(BuildContext context) {
    if (violations.isEmpty) {
      return VisitDetailNotice(
          text: 'All dispatch rules are met.'.tr,
          color: AppTheme.statGreen,
          icon: Icons.check_circle_rounded);
    }

    final sorted = [...violations]
      ..sort((a, b) => a.blocks == b.blocks ? 0 : (a.blocks ? -1 : 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final violation in sorted)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: VisitDetailNotice(
              text: violation.message,
              color: violation.blocks ? AppTheme.statOrange : AppTheme.pending,
              icon: violation.blocks
                  ? Icons.block
                  : Icons.warning_amber_rounded,
            ),
          ),
      ],
    );
  }
}
