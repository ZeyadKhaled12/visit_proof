import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../configs/app_toasts.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_search.dart';
import '../../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../data/models/invoice_detail_model.dart';
import '../../controller/invoices_bloc.dart';
import 'invoices_widget_card.dart';
import 'invoices_widget_filter_sheet.dart';
import 'invoices_widget_filters.dart';

class InvoicesBody extends StatefulWidget {
  const InvoicesBody(
      {super.key, required this.invoices, required this.loading});
  final List<InvoiceDetailModel> invoices;
  final bool loading;

  @override
  State<InvoicesBody> createState() => _InvoicesBodyState();
}

class _InvoicesBodyState extends State<InvoicesBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  InvoicesFilter _filter = const InvoicesFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InvoiceDetailModel> get _visibleInvoices => widget.invoices
      .where((invoice) =>
          _filter.matches(invoice) &&
          GFunSearch.matches(_query, [
            invoice.invoiceNumber,
            invoice.visitNumber,
            invoice.client?.name,
            invoice.client?.phone,
          ]))
      .toList();

  void _refresh() => context
      .read<InvoicesBloc>()
      .add(GetInvoicesEvent(noParameters: NoParameters()));

  Future<void> _openFilters() async {
    final data = await AppToasts.showBottomSheet(
        context, InvoicesWidgetFilterSheet(filter: _filter));
    if (data is InvoicesFilter) setState(() => _filter = data);
  }

  void _clearSearchAndFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = const InvoicesFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoices = _visibleInvoices;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: GWidgetAppbar(title: 'Invoices'.tr, icon: Icons.receipt_long_outlined)
          .appbar(),
      body: GWidgetLoading(
        isLoading: widget.loading,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 5),
              InvoicesWidgetFilters(
                searchController: _searchController,
                onSearch: (value) => setState(() => _query = value),
                activeFilters: _filter.activeCount,
                onFilter: _openFilters,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async => _refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount: invoices.isEmpty ? 1 : invoices.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (invoices.isEmpty) return _emptyState();
                      return InvoicesWidgetCard(
                          invoice: invoices[index], onReturn: _refresh);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    if (widget.loading) return const SizedBox.shrink();

    if (widget.invoices.isEmpty) {
      return GWidgetEmpty(
        icon: Icons.receipt_long_rounded,
        title: 'No invoices yet'.tr,
        subtitle: 'An invoice is created automatically with every new visit.'.tr,
      );
    }

    return GWidgetEmpty(
      icon: Icons.search_off_rounded,
      title: 'No matching invoices'.tr,
      subtitle: 'Try another search or clear the filters.'.tr,
      actionText: 'Clear search & filters'.tr,
      onAction: _clearSearchAndFilters,
    );
  }
}
