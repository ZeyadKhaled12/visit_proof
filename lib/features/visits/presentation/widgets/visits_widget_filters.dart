import 'package:flutter/material.dart';

import '../../../../core/utils/general_widgets/g_widget_filter_btn.dart';
import '../../../../core/utils/general_widgets/g_widget_search.dart';

class VisitsWidgetFilters extends StatelessWidget {
  const VisitsWidgetFilters({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.activeFilters,
    required this.onFilter,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final int activeFilters;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: GWidgetSearch(
                hint: 'Search visit number, client, service...',
                searchController: searchController,
                onChanged: (value) => onSearch(value ?? ''),
                onClear: () {
                  searchController.clear();
                  onSearch('');
                })),
        const SizedBox(width: 12),
        GWidgetFilterBtn(activeCount: activeFilters, onTap: onFilter),
      ],
    );
  }
}
