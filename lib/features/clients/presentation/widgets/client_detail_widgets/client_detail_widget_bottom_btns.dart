import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_client_detail_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/remove_client_uc.dart';
import 'package:visit_proof/features/clients/presentation/controller/clients_bloc.dart';
import 'package:visit_proof/features/clients/presentation/screens/add_client_scr.dart';
import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../data/models/client_detail_model/client_detail_model.dart';

class ClientDetailWidgetBottomBtns extends StatelessWidget {
  const ClientDetailWidgetBottomBtns(
      {super.key,
      required this.clientDetailModel,
      required this.removeLoading});
  final bool removeLoading;
  final ClientDetailModel clientDetailModel;

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
              text: 'Edit Client'.tr,
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
                    context, AddClientScr.route,
                    arguments:
                        AddClientArgu(client: clientDetailModel).toArgu());
                if (data is bool) {
                  if (data) {
                    if (clientDetailModel.id != null) {
                      context.read<ClientsBloc>().add(GetClientDetailEvent(
                          getClientDetailParameters: GetClientDetailParameters(
                              clientID: clientDetailModel.id!)));
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
                if (clientDetailModel.visits?.isNotEmpty ?? false) {
                  AppToasts.showMessage(
                      'This client cannot be deleted because they have existing visits'.tr,
                      isError: true);
                  return;
                }

                final data = await AppToasts.showDeleteConfirmation(
                    headTitle: 'Remove Client?'.tr,
                    title:
                        'Are you sure you want to remove {0}? This action cannot be undone.'.trArgs([clientDetailModel.name ?? '--']));
                if (data is bool) {
                  if (data) {
                    if (clientDetailModel.id != null) {
                      context.read<ClientsBloc>().add(RemoveClientEvent(
                          removeClientParameters: RemoveClientParameters(
                              clientID: clientDetailModel.id!)));
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
