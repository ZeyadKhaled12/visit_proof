import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../../core/utils/general_widgets/g_widget_excel.dart';
import '../../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../data/models/invoice_detail_model.dart';
import 'invoices_widget_card.dart';
import 'invoices_widget_filters.dart';

class InvoicesBody extends StatelessWidget {
  const InvoicesBody(
      {super.key, required this.invoices, required this.loading});
  final List<InvoiceDetailModel> invoices;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: GWidgetAppbar(
          title: 'Invoices',
          icon: Icons.fact_check_outlined,
          actions: [
            Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GWidgetExcel()),
            ),
          ]).appbar(),
      body: GWidgetLoading(
        isLoading: loading,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: invoices.isEmpty
              ? Center(
                  child: Text('No invoices yet',
                      style: AppFonts(color: AppColors.textDarkHint)))
              : Column(
                  children: [
                    const SizedBox(height: 5),
                    InvoicesWidgetFilters(),
                    SizedBox(height: 16),
                    Expanded(
                        child: Container(
                      color: AppColors.scaffoldBackground,
                      child: ListView.separated(
                        itemCount: invoices.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: index == invoices.length - 1
                                  ? EdgeInsets.only(bottom: 140)
                                  : EdgeInsets.zero,
                              child:
                                  InvoicesWidgetCard(invoice: invoices[index]));
                        },
                      ),
                    ))
                  ],
                ),
        ),
      ),
    );
  }
}
