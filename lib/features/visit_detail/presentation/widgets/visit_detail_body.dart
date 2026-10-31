import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/enums/priority_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_loading.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_navi_body.dart';
import 'package:visit_proof/core/utils/enums.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/usecases/visit_detail_actions_uc.dart';
import '../controller/visit_detail_bloc.dart';
import 'visit_detail_panels.dart';
import 'visit_detail_status_sheet.dart';
import 'visit_detail_assign_sheet.dart';
import 'visit_detail_edit_sheet.dart';
import 'visit_detail_comment_sheet.dart';

class VisitDetailBody extends StatelessWidget {
  final VisitDetailState state;
  final String visitID;
  const VisitDetailBody({super.key, required this.state, required this.visitID});

  Future<T?> _sheet<T>(BuildContext context, Widget body) => showModalBottomSheet<T>(
    context: context, isScrollControlled: true, useSafeArea: true,
    backgroundColor: AppColors.surfaceWhite,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => body,
  );

  void _dispatch(BuildContext context, Object? value) {
    if (value is ChangeVisitStatusParameters) context.read<VisitDetailBloc>().add(ChangeVisitStatusEvent(value));
    if (value is UpdateVisitParameters) context.read<VisitDetailBloc>().add(UpdateVisitEvent(value));
    if (value is AssignVisitTechnicianParameters) context.read<VisitDetailBloc>().add(AssignVisitTechnicianEvent(value));
    if (value is UnassignVisitTechnicianParameters) context.read<VisitDetailBloc>().add(UnassignVisitTechnicianEvent(value));
    if (value is AddVisitCommentParameters) context.read<VisitDetailBloc>().add(AddVisitCommentEvent(value));
  }

  Future<void> _comment(BuildContext context, VisitDetailModel visit) async {
    final result = await _sheet<String>(context, const VisitDetailCommentSheet());
    if (!context.mounted || result == null) return;
    _dispatch(context, AddVisitCommentParameters(visitID: visit.id!, comment: result));
  }

  Widget _action(BuildContext context, String label, IconData icon, VoidCallback onTap,
      {bool prominent = false}) => Expanded(child: Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Container(
          constraints: const BoxConstraints(minHeight: 70), padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(color: prominent ? AppColors.primary : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: prominent ? AppColors.primary : AppColors.iconLightGrey.withValues(alpha: .3))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: prominent ? AppColors.surfaceWhite : AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: AppFonts(
              color: prominent ? AppColors.surfaceWhite : AppColors.textPrimary,
              fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        )),
      ));

  String _date(DateTime? date) => date == null ? '—' : date.toLocal().toString().split('.').first;

  @override Widget build(BuildContext context) {
    final visit = state.visit;
    return GWidgetNaviBody(title: 'Visit details', body: GWidgetLoading(
      isLoading: state.actionState == RequestState.loading,
      body: visit == null
          ? Center(child: state.getState == RequestState.loading
              ? const GWidgetLoadingCircle(color: AppColors.primary, height: 34, width: 34)
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Visit could not be loaded', style: AppFonts(color: AppColors.textSecondary)),
                  TextButton(onPressed: () => context.read<VisitDetailBloc>().add(LoadVisitDetailEvent(visitID)),
                    child: Text('Retry', style: AppFonts(color: AppColors.primary))),
                ]))
          : RefreshIndicator(color: AppColors.primary, onRefresh: () async {
              final bloc = context.read<VisitDetailBloc>();
              final completed = bloc.stream.firstWhere((s) => s.getState == RequestState.loaded || s.getState == RequestState.error);
              bloc.add(LoadVisitDetailEvent(visitID));
              await completed;
            }, child: ListView(padding: const EdgeInsets.fromLTRB(16, 22, 16, 32), children: [
              Container(padding: const EdgeInsets.all(21), decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.circular(24)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Expanded(child: Text(visit.visitNumber ?? 'Visit', style: AppFonts(
                    color: AppColors.surfaceWhite, fontWeight: FontWeight.w800, fontSize: 19))),
                    VisitStatusBadge(status: visit.status, onDark: true)]),
                  const SizedBox(height: 18),
                  Text(visit.serviceName ?? 'Service not selected', style: AppFonts(
                    color: AppColors.surfaceWhite, fontWeight: FontWeight.w800, fontSize: 21)),
                  const SizedBox(height: 8),
                  Text('${visit.client?.name ?? 'No customer'} · ${_date(visit.startDate)}',
                    style: AppFonts(color: AppColors.surfaceWhite, fontSize: 12)),
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                _action(context, 'Change status', Icons.alt_route_rounded, () async {
                  final result = await _sheet<ChangeVisitStatusParameters>(context, VisitDetailStatusSheet(visit: visit));
                  if (context.mounted) _dispatch(context, result);
                }, prominent: true),
                const SizedBox(width: 9),
                _action(context, 'Add comment', Icons.add_comment_outlined, () => _comment(context, visit)),
                if ({VisitStatus.draft,VisitStatus.scheduled,VisitStatus.assigned}.contains(visit.status)) ...[
                  const SizedBox(width: 9),
                  _action(context, visit.technicianModel == null ? 'Assign' : 'Reassign',
                    Icons.engineering_outlined, () async {
                      final result = await _sheet<Object>(context, VisitDetailAssignSheet(
                        visit: visit, technicians: state.technicians));
                      if (context.mounted) _dispatch(context, result);
                    }),
                ],
              ]),
              if (![VisitStatus.completed, VisitStatus.cancel].contains(visit.status)) ...[
                const SizedBox(height: 4),
                GWidgetButton(text: 'Edit visit information', fontSize: 13,
                  backgroundColor: AppColors.surfaceWhite, colorText: AppColors.primary,
                  border: Border.all(color: AppColors.primary.withValues(alpha: .25)),
                  widget: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 17),
                  onPressed: () async {
                    final result = await _sheet<UpdateVisitParameters>(context, VisitDetailEditSheet(
                      visit: visit, clients: state.clients, services: state.services));
                    if (context.mounted) _dispatch(context, result);
                  }),
                const SizedBox(height: 12),
              ],
              VisitDetailPanel(title: 'Customer & location', icon: Icons.location_on_outlined,
                child: Column(children: [
                  VisitDetailLine(label: 'Customer', value: visit.client?.name ?? '—'),
                  VisitDetailLine(label: 'Phone', value: visit.client?.phone ?? '—'),
                  VisitDetailLine(label: 'City', value: visit.site?.city?.name ?? '—'),
                  VisitDetailLine(label: 'Site', value: visit.site?.addressDetail ?? '—'),
                ])),
              const SizedBox(height: 14),
              VisitDetailPanel(title: 'Work & scheduling', icon: Icons.handyman_outlined,
                child: Column(children: [
                  VisitDetailLine(label: 'Service', value: visit.serviceName ?? '—'),
                  VisitDetailLine(label: 'Category', value: visit.category?.name ?? '—'),
                  VisitDetailLine(label: 'Technician', value: visit.technicianModel?.name ?? 'Not assigned'),
                  VisitDetailLine(label: 'Start', value: _date(visit.startDate)),
                  VisitDetailLine(label: 'Duration', value: '${visit.durationInMin ?? 0} min'),
                  VisitDetailLine(label: 'Priority', value: PrioritySwitch(priorityEnum: visit.priority).getText()),
                ])),
              const SizedBox(height: 14),
              VisitDetailPanel(title: 'Financial link', icon: Icons.receipt_long_outlined,
                child: Column(children: [
                  VisitDetailLine(label: 'Price', value: '${visit.price?.toStringAsFixed(2) ?? '—'}'),
                  VisitDetailLine(label: 'Payment', value: PaymentStatusSwitch(paymentStatusEnum: visit.paymentStatus).getText()),
                  VisitDetailLine(label: 'Linked invoice', value: visit.invoiceID ?? 'Missing'),
                ])),
              const SizedBox(height: 14),
              VisitDetailPanel(title: 'Service checklist & proof', icon: Icons.fact_check_outlined,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ...(visit.checkList ?? []).map((t) => Padding(padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [const Icon(Icons.circle_outlined, size: 15, color: AppColors.primary),
                      const SizedBox(width: 9), Expanded(child: Text(t, style: AppFonts(color: AppColors.textPrimary, fontSize: 12)))]))),
                  VisitDetailLine(label: 'Before-work photos', value: visit.requireBeforeWorkPhotos == true ? 'Required' : 'Optional'),
                  VisitDetailLine(label: 'After-work photos', value: visit.requireAfterWorkPhotos == true ? 'Required' : 'Optional'),
                  Text('Requirements only: completion evidence is not part of this VisitDetailModel.',
                    style: AppFonts(color: AppColors.textSecondary, fontSize: 11)),
                ])),
              if ((visit.problemDescription ?? '').trim().isNotEmpty || (visit.notes ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                VisitDetailPanel(title: 'Instructions & notes', icon: Icons.notes_outlined,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if ((visit.problemDescription ?? '').trim().isNotEmpty)
                      Text(visit.problemDescription!, style: AppFonts(color: AppColors.textPrimary, fontSize: 12)),
                    if ((visit.notes ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text(visit.notes!, style: AppFonts(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ])),
              ],
              const SizedBox(height: 14), VisitHistoryPanel(visit: visit),
            ])),
    ));
  }
}
