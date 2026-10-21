import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../../../core/utils/general_widgets/g_widget_navi_appbar.dart';
import '../../../../clients/presentation/widgets/client_detail_widgets/client_detail_widget_title_card.dart';
import '../../../../clients/presentation/widgets/client_detail_widgets/client_detail_widget_visits.dart';
import '../../../data/models/technician_detail_model.dart';
import 'tech_detail_widget_bottom_btns.dart';
import 'tech_detail_widget_categories.dart';
import 'tech_detail_widget_header.dart';

class TechnicianDetailBody extends StatelessWidget {
  const TechnicianDetailBody(
      {super.key,
      required this.technicianDetailModel,
      required this.loading,
      required this.removeClientLoading});
  final TechnicianDetailModel technicianDetailModel;
  final bool removeClientLoading;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: GWidgetNaviAppbar.appBar(context, 'Technician Detail'),
        bottomNavigationBar: loading
            ? null
            : TechDetailWidgetBottomBtns(
                removeLoading: removeClientLoading,
                technicianDetailModel: technicianDetailModel),
        body: GWidgetLoading(
          isLoading: loading,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: TechDetailWidgetHeader(
                      technicianDetailModel: technicianDetailModel)),

              // // Equipments Section
              SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: TechDetailWidgetCategories(
                      categories: technicianDetailModel.categories
                              ?.map((e) => e.name ?? '')
                              .toList() ??
                          [],
                    )),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Sticky Visit History Title
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: ClientDetailWidgetTitle(
                          title: 'Visit History', icon: Icons.history),
                    ),
                    height: 60),
              ),

              // Visit History List
              ClientDetailWidgetVisits(
                  visits: technicianDetailModel.visits ?? []),

              // Bottom padding for safe scrolling
              const SliverToBoxAdapter(child: SizedBox(height: 24))
            ],
          ),
        ),
      ),
    );
  }
}

// Delegate for the Sticky Header
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
