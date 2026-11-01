import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_widgets/g_widget_location_picker_scr.dart';
import '../../../../../core/utils/general_widgets/g_widget_map_picked.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import 'package:latlong2/latlong.dart';

class AddClientWidgetLocation extends StatelessWidget {
  const AddClientWidgetLocation(
      {super.key,
      required this.addressController,
      this.addressDetailErrorMsg,
      required this.onPickFromMap,
      this.location});

  final TextEditingController addressController;
  final String? addressDetailErrorMsg;
  final LatLng? location;
  final Function(LatLng location) onPickFromMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.iconLightGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          GWidgetMapPicked(
              onTap: () async {
                final data = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GWidgetLocationPickerScr(
                            initialLocation: location)));
                if (data != null) {
                  if (data is LatLng) {
                    onPickFromMap(data);
                  }
                }
              },
              location: location),
          SizedBox(height: 10),
          GWidgetTextField(
              controller: addressController,
              labelText: 'Detailed Address'.tr,
              hintText: 'Building, Street, Area...'.tr,
              maxLength: 500,
              prefixIcon: Icon(Icons.home_work_outlined,
                  color: AppTheme.primary),
              errorMsg: addressDetailErrorMsg),
        ],
      ),
    );
  }
}
