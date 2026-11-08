import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../dispatch_widget_action_sheet.dart';
import '../dispatch_widget_visit_card.dart';

/// A filtered list of visits, e.g. the conflicts or late visits counter.
class DispatchWidgetVisitListSheet extends StatelessWidget {
  const DispatchWidgetVisitListSheet(
      {super.key, required this.title, required this.visitIDs});
  final String title;
  final List<String?> visitIDs;

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      help: 'The visits behind the number you tapped.'.tr,
      title: title,
      builder: (context, state, loading) {
        final visits = [
          for (final id in visitIDs) state.visitById(id),
        ].whereType<VisitDetailModel>().toList();

        if (visits.isEmpty) {
          return VisitDetailEmpty(
              icon: Icons.task_alt_rounded, text: 'Nothing here right now'.tr);
        }

        return Column(
          children: [
            for (final visit in visits)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DispatchWidgetVisitCard(visit: visit, day: state.day),
              ),
          ],
        );
      },
    );
  }
}
