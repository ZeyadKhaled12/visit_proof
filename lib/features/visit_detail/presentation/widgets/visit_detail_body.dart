import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../configs/app_toasts.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
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
import 'visit_detail_widget_photos.dart';
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
    // On a finished visit the office reads the proof before the money.
    final proofFirst = VisitRules.canManageInvoice() &&
        VisitRules.statusOf(visit) == VisitStatus.completed;
    final history = [
      gap,
      GTourTarget(id: 'history', child: VisitDetailWidgetHistory(
          history: visit.history ?? const [],
          canAddNote: VisitRules.canAddComment(visit))),
    ];

    return GWidgetLoading(
      isLoading: state.getVisitDetailRequestState == RequestState.loading,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async => _refresh(context),
        child: ListView(
          cacheExtent: 100000, // keeps every section built for the guided tour
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            GTourTarget(id: 'hero', child: VisitDetailWidgetHero(visit: visit)),
            gap,
            GTourTarget(id: 'workflow', child: VisitDetailWidgetWorkflow(visit: visit, invoice: invoice)),
            gap,
            GTourTarget(id: 'client', child: VisitDetailWidgetClient(visit: visit)),
            gap,
            GTourTarget(id: 'schedule', child: VisitDetailWidgetSchedule(visit: visit)),
            gap,
            GTourTarget(id: 'service', child: VisitDetailWidgetService(visit: visit, invoice: invoice)),
            gap,
            GTourTarget(id: 'info', child: VisitDetailWidgetInfo(visit: visit)),
            if (VisitDetailWidgetPhotos.shouldShow(visit)) ...[
              gap,
              GTourTarget(id: 'photos', child: VisitDetailWidgetPhotos(visit: visit)),
            ],
            if (proofFirst) ...history,
            if (VisitRules.canSeeInvoice(visit)) ...[
              gap,
              GTourTarget(id: 'invoice', child: VisitDetailWidgetInvoice(
                visit: visit,
                invoice: invoice,
                loading: state.getInvoiceRequestState == RequestState.loading,
                onInvoiceClosed: () => _refresh(context),
              )),
            ],
            if (!proofFirst) ...history,
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
                  padding: EdgeInsetsDirectional.only(start: 8),
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
