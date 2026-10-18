import 'package:flutter/material.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_loading.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_navi_appbar.dart';

import '../../../../../configs/app_colors.dart';
import '../../../data/models/client_detail_model/client_detail_model.dart';
import 'client_detail_widget_bottom_btns.dart';
import 'client_detail_widget_equipments.dart';
import 'client_detail_widget_header.dart';
import 'client_detail_widget_title_card.dart';
import 'client_detail_widget_visits.dart';

class ClientDetailBody extends StatelessWidget {
  const ClientDetailBody(
      {super.key,
      required this.client,
      required this.laoding,
      required this.removeClientLoading,
      required this.addEquipmentLoading,
      required this.removeEquipmentLoading,
      required this.equipmentIDLoading});
  final ClientDetailModel client;
  final bool removeClientLoading;
  final bool removeEquipmentLoading;
  final bool addEquipmentLoading;
  final String equipmentIDLoading;
  final bool laoding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: GWidgetNaviAppbar.appBar(context, 'Client Details'),
        bottomNavigationBar: laoding
            ? null
            : ClientDetailWidgetBottomBtns(
                removeLoading: removeClientLoading, clientDetailModel: client),
        body: GWidgetLoading(
          isLoading: laoding,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Profile section
              SliverToBoxAdapter(
                  child: ClientDetailWidgetHeader(clientDetailModel: client)),

              // Equipments Section
              SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: ClientDetailWidgetEquipments(
                        equipmentIDLoading: equipmentIDLoading,
                        removeEquipmentLoading: removeEquipmentLoading,
                        clientID: client.id ?? "",
                        addEquipmentLoading: addEquipmentLoading,
                        equipments: client.equipments ?? [])),
              ),

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
              ClientDetailWidgetVisits(visits: client.visits ?? []),

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
