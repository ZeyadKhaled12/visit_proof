import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_bottom_sheet.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_choice_chip.dart';
import '../../data/models/visit_detail_models/visit_detail_model.dart';

/// Active filters of the visits list. Empty sets mean "any".
class VisitsFilter {
  final Set<VisitStatus> statuses;
  final Set<PaymentStatus> payments;
  final Set<Priority> priorities;

  const VisitsFilter({
    this.statuses = const {},
    this.payments = const {},
    this.priorities = const {},
  });

  int get activeCount => statuses.length + payments.length + priorities.length;

  bool matches(VisitDetailModel visit) =>
      (statuses.isEmpty ||
          statuses.contains(visit.status ?? VisitStatus.draft)) &&
      (payments.isEmpty ||
          payments.contains(visit.paymentStatus ?? PaymentStatus.unpaid)) &&
      (priorities.isEmpty ||
          priorities.contains(visit.priority ?? Priority.normal));
}

class VisitsWidgetFilterSheet extends StatefulWidget {
  const VisitsWidgetFilterSheet({super.key, required this.filter});
  final VisitsFilter filter;

  @override
  State<VisitsWidgetFilterSheet> createState() =>
      _VisitsWidgetFilterSheetState();
}

class _VisitsWidgetFilterSheetState extends State<VisitsWidgetFilterSheet> {
  late final Set<VisitStatus> _statuses = {...widget.filter.statuses};
  late final Set<PaymentStatus> _payments = {...widget.filter.payments};
  late final Set<Priority> _priorities = {...widget.filter.priorities};

  void _toggle<T>(Set<T> set, T value) => setState(
      () => set.contains(value) ? set.remove(value) : set.add(value));

  @override
  Widget build(BuildContext context) {
    return GWidgetBottomSheet(
      title: 'Filter visits'.tr,
      subtitle: 'Pick one or more options in each group'.tr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Group(
            title: 'Visit status'.tr,
            children: VisitStatus.values.map((status) {
              final info = VisitStatusSwitch(visitStatusEnum: status);
              return GWidgetChoiceChip(
                label: info.getText(),
                color: info.getColor(),
                selected: _statuses.contains(status),
                onTap: () => _toggle(_statuses, status),
              );
            }).toList(),
          ),
          _Group(
            title: 'Payment'.tr,
            children: PaymentStatus.values.map((status) {
              final info = PaymentStatusSwitch(paymentStatusEnum: status);
              return GWidgetChoiceChip(
                label: info.getText(),
                color: info.getColor(),
                selected: _payments.contains(status),
                onTap: () => _toggle(_payments, status),
              );
            }).toList(),
          ),
          _Group(
            title: 'Priority'.tr,
            children: Priority.values.map((priority) {
              final info = PrioritySwitch(priorityEnum: priority);
              return GWidgetChoiceChip(
                label: info.getText(),
                color: info.getColor(),
                selected: _priorities.contains(priority),
                onTap: () => _toggle(_priorities, priority),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GWidgetButton(
                  text: 'Reset'.tr,
                  fontSize: AppTheme.textSubtitle,
                  raduis: 14,
                  colorText: AppTheme.iconGrey,
                  backgroundColor: AppTheme.cardColor,
                  border: Border.all(color: AppTheme.iconGrey),
                  onPressed: () =>
                      Navigator.pop(context, const VisitsFilter()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GWidgetButton(
                  text: 'Apply'.tr,
                  fontSize: AppTheme.textSubtitle,
                  raduis: 14,
                  onPressed: () => Navigator.pop(
                      context,
                      VisitsFilter(
                          statuses: _statuses,
                          payments: _payments,
                          priorities: _priorities)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textBodyLarge,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}
