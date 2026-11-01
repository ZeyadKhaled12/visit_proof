import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../configs/app_toasts.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../domain/rules/visit_rules.dart';
import '../../domain/usecases/delete_visit_uc.dart';
import '../../domain/usecases/get_visit_detail_uc.dart';
import '../controller/visit_detail_bloc.dart';
import 'visit_detail_widget_client.dart';
import 'visit_detail_widget_hero.dart';
import 'visit_detail_widget_history.dart';
import 'visit_detail_widget_info.dart';
import 'visit_detail_widget_invoice.dart';
import 'visit_detail_widget_schedule.dart';
import 'visit_detail_widget_service.dart';
import 'visit_detail_widget_workflow.dart';

class VisitDetailBody extends StatelessWidget {
  const VisitDetailBody(
      {super.key, required this.visitID, required this.state});
  final String visitID;
  final VisitDetailState state;

  void _refresh(BuildContext context) {
    context.read<VisitDetailBloc>().add(GetVisitDetailEvent(
        getVisitDetailParameters:
            GetVisitDetailParameters(visitID: visitID)));
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await AppToasts.showDeleteConfirmation(
        headTitle: 'Delete visit?'.tr,
        title: 'This permanently removes the visit and its draft invoice.'.tr);
    if (confirmed != true || !context.mounted) return;
    context.read<VisitDetailBloc>().add(DeleteVisitEvent(
        deleteVisitParameters: DeleteVisitParameters(visitID: visitID)));
  }

  @override
  Widget build(BuildContext context) {
    return GWidgetNaviBody(
      title: 'Visit Details'.tr,
      body: state.hasVisit ? _content(context) : _placeholder(context),
    );
  }

  /// First load: a spinner, or a retry card if the visit cannot be loaded.
  Widget _placeholder(BuildContext context) {
    if (state.getVisitDetailRequestState != RequestState.error) {
      return Center(
          child: GWidgetLoadingCircle(color: AppTheme.primary, strokeWidth: 4));
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.statOrange.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded,
                  color: AppTheme.statOrange, size: 38),
            ),
            const SizedBox(height: 16),
            Text('We could not load this visit'.tr,
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textTitle,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            GWidgetButton(
              text: 'Try again'.tr,
              fontSize: AppTheme.textSubtitle,
              width: 160,
              raduis: 12,
              onPressed: () => _refresh(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final visit = state.visit;
    final invoice = state.linkedInvoice;
    const gap = SizedBox(height: 16);

    return GWidgetLoading(
      isLoading: state.getVisitDetailRequestState == RequestState.loading,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async => _refresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            VisitDetailWidgetHero(visit: visit),
            gap,
            VisitDetailWidgetWorkflow(visit: visit, invoice: invoice),
            gap,
            VisitDetailWidgetClient(visit: visit),
            gap,
            VisitDetailWidgetSchedule(visit: visit),
            gap,
            VisitDetailWidgetService(visit: visit, invoice: invoice),
            gap,
            VisitDetailWidgetInfo(visit: visit),
            gap,
            VisitDetailWidgetInvoice(
              invoice: invoice,
              loading: state.getInvoiceRequestState == RequestState.loading,
              onInvoiceClosed: () => _refresh(context),
            ),
            gap,
            VisitDetailWidgetHistory(history: visit.history ?? const []),
            if (VisitRules.canDelete(visit, invoice)) ...[
              const SizedBox(height: 24),
              GWidgetButton(
                text: 'Delete visit'.tr,
                fontSize: AppTheme.textSubtitle,
                raduis: 14,
                height: 50,
                colorText: AppTheme.statOrange,
                loadingColor: AppTheme.statOrange,
                loadingSize: 20,
                loadingStrokeWidth: 2.5,
                backgroundColor: AppTheme.statOrange.withValues(alpha: .08),
                border: Border.all(color: AppTheme.statOrange),
                isLoading:
                    state.deleteVisitRequestState == RequestState.loading,
                widget: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.delete_outline_rounded,
                      color: AppTheme.statOrange, size: 20),
                ),
                onPressed: () => _delete(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
