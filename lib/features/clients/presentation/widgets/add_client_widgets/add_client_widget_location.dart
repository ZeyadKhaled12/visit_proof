import 'package:flutter/material.dart';
import '../../../../../configs/app_colors.dart';
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
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.iconLightGrey.withValues(alpha: 0.3)),
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
              labelText: 'Detailed Address',
              hintText: 'Building, Street, Area...',
              maxLength: 500,
              prefixIcon: const Icon(Icons.home_work_outlined,
                  color: AppColors.primary),
              errorMsg: addressDetailErrorMsg),
        ],
      ),
    );
  }
}
