import 'package:flutter/material.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_bottom_sheet.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_choice_chip.dart';
import '../../../data/models/invoice_detail_model.dart';

enum InvoiceStage { draft, issued, overdue }

/// Active filters of the invoices list. Empty sets mean "any".
class InvoicesFilter {
  final Set<PaymentStatus> payments;
  final Set<InvoiceStage> stages;

  const InvoicesFilter({this.payments = const {}, this.stages = const {}});

  int get activeCount => payments.length + stages.length;

  bool matches(InvoiceDetailModel invoice) =>
      (payments.isEmpty ||
          payments.contains(invoice.paymentStatus ?? PaymentStatus.unpaid)) &&
      (stages.isEmpty || stages.any((stage) => _isInStage(invoice, stage)));

  static bool _isInStage(InvoiceDetailModel invoice, InvoiceStage stage) {
    switch (stage) {
      case InvoiceStage.draft:
        return invoice.issueDate == null;
      case InvoiceStage.issued:
        return invoice.issueDate != null;
      case InvoiceStage.overdue:
        final now = DateTime.now();
        return invoice.issueDate != null &&
            invoice.dueDate != null &&
            (invoice.remainingAmount ?? 0) > 0 &&
            invoice.dueDate!.isBefore(DateTime(now.year, now.month, now.day));
    }
  }
}

class InvoicesWidgetFilterSheet extends StatefulWidget {
  const InvoicesWidgetFilterSheet({super.key, required this.filter});
  final InvoicesFilter filter;

  @override
  State<InvoicesWidgetFilterSheet> createState() =>
      _InvoicesWidgetFilterSheetState();
}

class _InvoicesWidgetFilterSheetState extends State<InvoicesWidgetFilterSheet> {
  static Map<InvoiceStage, (String, Color)> get _stageStyle => {
    InvoiceStage.draft: ('Draft', AppTheme.iconGrey),
    InvoiceStage.issued: ('Issued', AppTheme.secondary),
    InvoiceStage.overdue: ('Overdue', AppTheme.statOrange),
  };

  late final Set<PaymentStatus> _payments = {...widget.filter.payments};
  late final Set<InvoiceStage> _stages = {...widget.filter.stages};

  void _toggle<T>(Set<T> set, T value) => setState(
      () => set.contains(value) ? set.remove(value) : set.add(value));

  @override
  Widget build(BuildContext context) {
    return GWidgetBottomSheet(
      title: 'Filter invoices',
      subtitle: 'Pick one or more options in each group',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Group(
            title: 'Stage',
            children: InvoiceStage.values.map((stage) {
              final (label, color) = _stageStyle[stage]!;
              return GWidgetChoiceChip(
                label: label,
                color: color,
                selected: _stages.contains(stage),
                onTap: () => _toggle(_stages, stage),
              );
            }).toList(),
          ),
          _Group(
            title: 'Payment',
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GWidgetButton(
                  text: 'Reset',
                  fontSize: AppTheme.textSubtitle,
                  raduis: 14,
                  colorText: AppTheme.iconGrey,
                  backgroundColor: AppTheme.cardColor,
                  border: Border.all(color: AppTheme.iconGrey),
                  onPressed: () =>
                      Navigator.pop(context, const InvoicesFilter()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GWidgetButton(
                  text: 'Apply',
                  fontSize: AppTheme.textSubtitle,
                  raduis: 14,
                  onPressed: () => Navigator.pop(context,
                      InvoicesFilter(payments: _payments, stages: _stages)),
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
