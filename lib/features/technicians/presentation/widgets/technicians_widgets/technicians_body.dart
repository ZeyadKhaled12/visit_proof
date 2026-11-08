import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_loading.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_search.dart';
import '../../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../../core/utils/general_widgets/g_widget_floating_btn.dart';
import '../../../../../core/utils/general_widgets/g_widget_search.dart';
import '../../../data/models/technician_detail_model.dart';
import '../../../data/models/technician_model.dart';
import '../../screens/add_tech_scr.dart';
import '../technicians_widget_card.dart';

class TechniciansBody extends StatefulWidget {
  const TechniciansBody(
      {super.key, required this.technicians, required this.loading});
  final List<TechnicianModel> technicians;
  final bool loading;

  @override
  State<TechniciansBody> createState() => _TechniciansBodyState();
}

class _TechniciansBodyState extends State<TechniciansBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TechnicianModel> get _visibleTechnicians => widget.technicians
      .where((technician) => GFunSearch.matches(_query, [
            technician.name,
            technician.phone,
            ...?technician.categories?.map((e) => e.name),
          ]))
      .toList();

  Future<void> _addTechnician() async {
    final data = await Navigator.pushNamed(context, AddTechScr.route);
    if (data is TechnicianDetailModel && data.id != null && mounted) {
      context
          .read<TechBloc>()
          .add(GetTechniciansEvent(noParameters: NoParameters()));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final technicians = _visibleTechnicians;

    return Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: GWidgetAppbar(title: 'Technicians'.tr, )
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
                  hint: 'Search name, phone, specialty...'.tr,
                  onChanged: (value) => setState(() => _query = value ?? ''),
                  onClear: _clearSearch,
                ),
                const SizedBox(height: 16),
                Expanded(
                    child: technicians.isEmpty
                        ? (widget.loading
                            ? const SizedBox.shrink()
                            : SingleChildScrollView(child: _emptyState()))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: technicians.length,
                            itemBuilder: (context, index) =>
                                TechnicianWidgetCard(
                                    technician: technicians[index]),
                          )),
              ],
            ),
          ),
        ),
        floatingActionButton: GWidgetFloatingBtn(
            text: "Add new technician".tr, onPressed: _addTechnician));
  }

  Widget _emptyState() {
    if (widget.technicians.isEmpty) {
      return GWidgetEmpty(
        icon: Icons.engineering_rounded,
        title: 'No technicians yet'.tr,
        subtitle: 'Add technicians so you can assign them to visits.'.tr,
        actionText: 'Add first technician'.tr,
        onAction: _addTechnician,
      );
    }
    return GWidgetEmpty(
      icon: Icons.search_off_rounded,
      title: 'No matching technicians'.tr,
      subtitle: 'Try a different name, phone or specialty.'.tr,
      actionText: 'Clear search'.tr,
      onAction: _clearSearch,
    );
  }
}
