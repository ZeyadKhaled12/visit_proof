import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/core/utils/general_models/g_model_equipment.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_loading.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_text_field.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_equipment_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/remove_equipment_uc.dart';
import 'package:visit_proof/features/clients/presentation/controller/clients_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import 'client_detail_widget_title_card.dart';

class ClientDetailWidgetEquipments extends StatelessWidget {
  const ClientDetailWidgetEquipments(
      {super.key,
      required this.equipments,
      required this.addEquipmentLoading,
      required this.clientID,
      required this.equipmentIDLoading,
      required this.removeEquipmentLoading});
  final String clientID;
  final List<GModelEquipment> equipments;
  final String equipmentIDLoading;
  final bool removeEquipmentLoading;
  final bool addEquipmentLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientDetailWidgetTitle(
            title: 'Equipments',
            icon: Icons.precision_manufacturing,
            addLoading: addEquipmentLoading,
            onAdd: () async {
              final data = await showDialog(
                context: context,
                builder: (context) => _AddEquipmentDialog(),
              );
              if (data is GModelEquipment) {
                context.read<ClientsBloc>().add(AddEquipmentEvent(
                    addEquipmentParameters: AddEquipmentParameters(
                        clientID: clientID, equipment: data)));
              }
            }),
        const SizedBox(height: 12),
        equipments.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.locationChipBg),
                ),
                child: Center(
                  child: Text(
                    'No equipments assigned to this client yet.',
                    style:
                        AppTheme.font(color: AppTheme.textLightHint, fontSize: AppTheme.textBody),
                  ),
                ),
              )
            : SizedBox(
                height: 125,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: equipments.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final eq = equipments[index];
                    return Container(
                      width: 220,
                      margin:
                          const EdgeInsets.only(right: 12, bottom: 4, top: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cardShadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                    AppTheme.secondary.withValues(alpha: 0.2),
                                child: Icon(Icons.settings,
                                    color: AppTheme.secondary, size: 14),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  eq.name ?? 'Unknown',
                                  style: AppTheme.font(
                                      color: AppTheme.textPrimary,
                                      fontSize: AppTheme.textBodyLarge,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final data =
                                      await AppToasts.showDeleteConfirmation(
                                          title:
                                              'Are you sure you want delete this equipment?');
                                  if (data is bool) {
                                    if (data) {
                                      if (eq.id == null) return;
                                      context.read<ClientsBloc>().add(
                                          RemoveEquipmentEvent(
                                              removeEquipmentParameters:
                                                  RemoveEquipmentParameters(
                                                      clientID: clientID,
                                                      equipmentID: eq.id!)));
                                    }
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundColor: AppTheme.statOrange
                                      .withValues(alpha: .2),
                                  radius: 12,
                                  child: equipmentIDLoading == eq.id &&
                                          removeEquipmentLoading
                                      ? GWidgetLoadingCircle(
                                          strokeWidth: 2.5,
                                          color: AppTheme.statOrange,
                                          width: 12,
                                          height: 12,
                                        )
                                      : Icon(
                                          Icons.delete,
                                          color: AppTheme.statOrange,
                                          size: 15,
                                        ),
                                ),
                              )
                            ],
                          ),
                          const Spacer(),
                          _EqDetailRowModel(
                              label: 'Brand:', value: eq.brand ?? "N/A"),
                          const SizedBox(height: 4),
                          _EqDetailRowModel(
                              label: 'Model:', value: eq.model ?? "N/A"),
                          const SizedBox(height: 4),
                          _EqDetailRowModel(
                              label: 'SN:',
                              value: eq.serialNumber ?? "N/A",
                              isSn: true),
                        ],
                      ),
                    );
                  },
                ),
              )
      ],
    );
  }
}

class _EqDetailRowModel extends StatelessWidget {
  const _EqDetailRowModel(
      {required this.label, required this.value, this.isSn = false});
  final String label;
  final String value;
  final bool isSn;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTheme.font(color: AppTheme.textSecondary, fontSize: AppTheme.textSmall)),
        Text(
          value,
          style: AppTheme.font(
            color: isSn ? AppTheme.textLightHint : AppTheme.textPrimary,
            fontSize: AppTheme.textSmall,
            fontWeight: isSn ? FontWeight.normal : FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AddEquipmentDialog extends StatefulWidget {
  const _AddEquipmentDialog();

  @override
  State<_AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<_AddEquipmentDialog> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _brand = TextEditingController();
  final TextEditingController _model = TextEditingController();
  final TextEditingController _serialNumber = TextEditingController();

  String? _nameErrorMsg;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _model.dispose();
    _serialNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Add New Equipment',
        style: AppTheme.font(
          color: AppTheme.textPrimary,
          fontSize: AppTheme.textHeadline,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GWidgetTextField(
                controller: _name,
                hintText: 'Equipment Name',
                errorMsg: _nameErrorMsg,
                prefixIcon: Icon(
                  Icons.build_circle,
                  size: 20,
                  color: AppTheme.primary,
                )),
            const SizedBox(height: 12),
            GWidgetTextField(
                controller: _brand,
                hintText: 'Brand',
                prefixIcon: Icon(
                  Icons.branding_watermark,
                  size: 20,
                  color: AppTheme.primary,
                )),
            const SizedBox(height: 12),
            GWidgetTextField(
                controller: _model,
                hintText: 'Model',
                prefixIcon: Icon(
                  Icons.category,
                  size: 20,
                  color: AppTheme.primary,
                )),
            const SizedBox(height: 12),
            GWidgetTextField(
                controller: _serialNumber,
                hintText: 'Serial Number',
                prefixIcon: Icon(
                  Icons.qr_code,
                  size: 20,
                  color: AppTheme.primary,
                ))
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTheme.font(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: AppTheme.textBodyLarge),
          ),
        ),
        GWidgetButton(
          text: 'Save',
          width: 90,
          height: 40,
          paddingTopBottom: 0,
          backgroundColor: AppTheme.primary,
          raduis: 10,
          onPressed: () {
            setState(() {
              _nameErrorMsg = null;
            });
            if (_name.text.isEmpty) {
              setState(() {
                _nameErrorMsg = 'Equipment name is required';
              });
            } else {
              Navigator.pop(
                  context,
                  GModelEquipment(
                      name: _name.text,
                      brand: _brand.text.isEmpty ? null : _brand.text,
                      model: _model.text.isEmpty ? null : _model.text,
                      serialNumber: _serialNumber.text.isEmpty
                          ? null
                          : _serialNumber.text));
            }
          },
        ),
      ],
    );
  }
}
