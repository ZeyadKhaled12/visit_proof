import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_tech_detail_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/remove_technician_uc.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';
import 'package:visit_proof/features/technicians/presentation/screens/add_tech_scr.dart';

import '../../../../../configs/app_colors.dart';
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
        color: AppColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GWidgetButton(
              text: 'Edit Technician',
              backgroundColor: AppColors.secondary,
              height: 42,
              raduis: 12,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              widget: const Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Icon(Icons.edit_square, color: Colors.white, size: 16),
              ),
              onPressed: () async {
                final data = await Navigator.pushNamed(
                    context, AddTechScr.route,
                    arguments: AddTechArgu(
                            technicianDetailModel: technicianDetailModel)
                        .toArgu());
                if (data is bool) {
                  if (data) {
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
              text: 'Remove',
              colorText: AppColors.statOrange,
              backgroundColor: AppColors.statOrange.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.statOrange, width: 1.2),
              height: 42,
              raduis: 12,
              fontSize: 14,
              isLoading: removeLoading,
              loadingSize: 15,
              loadingColor: AppColors.statOrange,
              fontWeight: FontWeight.bold,
              widget: const Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Icon(Icons.delete_outline,
                    color: AppColors.statOrange, size: 16),
              ),
              onPressed: () async {
                if (technicianDetailModel.visits?.isNotEmpty ?? false) {
                  AppToasts.showMessage(
                      'This technician cannot be deleted because they have existing visits',
                      isError: true);
                  return;
                }

                final data = await AppToasts.showDeleteConfirmation(
                    headTitle: 'Remove Technician?',
                    title:
                        'Are you sure you want to remove ${technicianDetailModel.name ?? '--'}? This action cannot be undone.');
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
