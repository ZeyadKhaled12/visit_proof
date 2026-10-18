import 'package:flutter/material.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';

import '../../../../../configs/app_colors.dart';
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
              onPressed: () async {},
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
              onPressed: () async {},
            ),
          ),
        ],
      ),
    );
  }
}
