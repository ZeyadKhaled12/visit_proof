import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_search.dart';
import '../../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../../core/utils/general_widgets/g_widget_floating_btn.dart';
import '../../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../../../core/utils/general_widgets/g_widget_search.dart';
import '../../../data/models/service_model.dart';
import '../../controller/services_bloc.dart';
import '../../screens/add_service_scr.dart';
import 'services_widget_card.dart';

class ServicesBody extends StatefulWidget {
  const ServicesBody(
      {super.key, required this.services, required this.loading});
  final List<ServiceModel> services;
  final bool loading;

  @override
  State<ServicesBody> createState() => _ServicesBodyState();
}

class _ServicesBodyState extends State<ServicesBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceModel> get _visibleServices => widget.services
      .where((service) => GFunSearch.matches(_query, [
            service.serviceName,
            service.category?.name,
            ...?service.checkList,
          ]))
      .toList();

  Future<void> _addService() async {
    final data = await AddServiceScr.show(context);
    if (data is ServiceModel && mounted) {
      context
          .read<ServicesBloc>()
          .add(GetServicesEvent(noParameters: NoParameters()));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final services = _visibleServices;

    return Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: GWidgetAppbar(
                title: 'Services'.tr, icon: Icons.miscellaneous_services)
            .appbar(),
        body: GWidgetLoading(
          isLoading: widget.loading,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 5),
                GWidgetSearch(
                  searchController: _searchController,
                  hint: 'Search service, category, task...'.tr,
                  onChanged: (value) => setState(() => _query = value ?? ''),
                  onClear: _clearSearch,
                ),
                const SizedBox(height: 16),
                Expanded(
                    child: services.isEmpty
                        ? (widget.loading
                            ? const SizedBox.shrink()
                            : SingleChildScrollView(child: _emptyState()))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: services.length,
                            itemBuilder: (context, index) =>
                                ServicesWidgetCard(service: services[index]),
                          ))
              ],
            ),
          ),
        ),
        floatingActionButton:
            GWidgetFloatingBtn(text: "Add new service".tr, onPressed: _addService));
  }

  Widget _emptyState() {
    if (widget.services.isEmpty) {
      return GWidgetEmpty(
        icon: Icons.build_circle_rounded,
        title: 'No services yet'.tr,
        subtitle: 'Add the services you offer with their price and checklist.'.tr,
        actionText: 'Add first service'.tr,
        onAction: _addService,
      );
    }
    return GWidgetEmpty(
      icon: Icons.search_off_rounded,
      title: 'No matching services'.tr,
      subtitle: 'Try a different service or category name.'.tr,
      actionText: 'Clear search'.tr,
      onAction: _clearSearch,
    );
  }
}
