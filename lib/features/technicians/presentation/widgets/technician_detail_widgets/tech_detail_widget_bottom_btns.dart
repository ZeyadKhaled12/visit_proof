import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_tech_detail_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/remove_technician_uc.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';
import 'package:visit_proof/features/technicians/presentation/screens/add_tech_scr.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../configs/app_toasts.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';

class TechDetailWidgetBottomBtns extends StatelessWidget {
  const TechDetailWidgetBottomBtns(
      {super.key,
      required this.technicianDetailModel,
      required this.removeLoading});
  final bool removeLoading;
  final TechnicianDetailModel technicianDetailModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GWidgetButton(
              text: 'Edit Technician'.tr,
              backgroundColor: AppTheme.secondary,
              height: 42,
              raduis: 12,
              fontSize: AppTheme.textBodyLarge,
              fontWeight: FontWeight.bold,
              widget: Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Icon(Icons.edit_square, color: AppTheme.onPrimary, size: 16),
              ),
              onPressed: () async {
                final data = await Navigator.pushNamed(
                    context, AddTechScr.route,
                    arguments: AddTechArgu(
                            technicianDetailModel: technicianDetailModel)
                        .toArgu());
                if (data is TechnicianDetailModel) {
                  if (data.id != null) {
                    if (technicianDetailModel.id != null) {
                      context.read<TechBloc>().add(GetTechDetailEvent(
                          getTechDetailParameters: GetTechDetailParameters(
                              techID: technicianDetailModel.id!)));
                    }
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GWidgetButton(
              text: 'Remove'.tr,
              colorText: AppTheme.statOrange,
              backgroundColor: AppTheme.statOrange.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.statOrange, width: 1.2),
              height: 42,
              raduis: 12,
              fontSize: AppTheme.textBodyLarge,
              isLoading: removeLoading,
              loadingSize: 15,
              loadingColor: AppTheme.statOrange,
              fontWeight: FontWeight.bold,
              widget: Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Icon(Icons.delete_outline,
                    color: AppTheme.statOrange, size: 16),
              ),
              onPressed: () async {
                if (technicianDetailModel.visits?.isNotEmpty ?? false) {
                  AppToasts.showMessage(
                      'This technician cannot be deleted because they have existing visits'.tr,
                      isError: true);
                  return;
                }

                final data = await AppToasts.showDeleteConfirmation(
                    headTitle: 'Remove Technician?'.tr,
                    title:
                        'Are you sure you want to remove {0}? This action cannot be undone.'.trArgs([technicianDetailModel.name ?? '--']));
                if (data is bool) {
                  if (data) {
                    if (technicianDetailModel.id != null) {
                      context.read<TechBloc>().add(RemoveTechEvent(
                          removeTechnicianParameters:
                              RemoveTechnicianParameters(
                                  techID: technicianDetailModel.id!)));
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
