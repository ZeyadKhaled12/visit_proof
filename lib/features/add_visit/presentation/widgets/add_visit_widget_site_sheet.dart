import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:visit_proof/core/utils/general_models/g_model_site.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_bottom_sheet.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';

import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../core/utils/general_dummy_data.dart';
import '../../../../core/utils/general_models/g_model_catg.dart';
import '../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../clients/presentation/widgets/add_client_widgets/add_client_widget_location.dart';

class AddVisitWidgetSiteSheet extends StatefulWidget {
  const AddVisitWidgetSiteSheet({super.key, this.site});
  final GModelSite? site;

  @override
  State<AddVisitWidgetSiteSheet> createState() =>
      _AddVisitWidgetSiteSheetState();
}

class _AddVisitWidgetSiteSheetState extends State<AddVisitWidgetSiteSheet> {
  GModelCatg? _selectedCity;
  String? _cityErrorMsg;

  LatLng? _location;
  String? _addressErrorMsg;

  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    if (widget.site != null) {
      _selectedCity = widget.site?.city;
      if (widget.site?.latitude != null && widget.site?.longitude != null) {
        _location = LatLng(widget.site!.latitude!, widget.site!.longitude!);
      }
      _addressController.text = widget.site?.addressDetail ?? '';
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GWidgetBottomSheet(
        title: widget.site == null ? 'Add new site' : 'Update Site',
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GWidgetDropDown<GModelCatg>(
                value: _selectedCity,
                enableSearch: true,
                labelText: 'Select City *',
                errorMsg: _cityErrorMsg,
                prefixIcon:
                    const Icon(Icons.location_city, color: AppColors.primary),
                items: GeneralDummyData.getSaudiCities().map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city.name ?? '',
                        style: AppFonts(fontWeight: FontWeight.w500)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCity = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Address Configuration',
                style: AppFonts(
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              AddClientWidgetLocation(
                location: _location,
                onPickFromMap: (location) {
                  setState(() {
                    _location = location;
                  });
                },
                addressDetailErrorMsg: _addressErrorMsg,
                addressController: _addressController,
              ),
              const SizedBox(height: 25),
              GWidgetButton(
                onPressed: () {
                  setState(() {
                    _cityErrorMsg = null;
                    _addressErrorMsg = null;
                    if (_selectedCity == null) {
                      _cityErrorMsg = 'City is required';
                    }
                    if (_location == null && _addressController.text.isEmpty) {
                      _addressErrorMsg =
                          'Please provide an address detail or pick a location from the map.';
                    }
                    if (_location == null &&
                        (_addressController.text.length < 10 &&
                            _addressController.text.isNotEmpty)) {
                      _addressErrorMsg =
                          'Detailed address must be at least 10 characters long';
                    }
                  });
                  if (_cityErrorMsg != null || _addressErrorMsg != null) return;
                  GModelSite site = GModelSite(
                      city: _selectedCity,
                      latitude: _location?.latitude,
                      longitude: _location?.longitude,
                      addressDetail: _addressController.text);
                  Navigator.pop(context, site);
                },
                text: widget.site == null ? 'Add new Site' : 'Update Site',
              )
            ],
          ),
        ));
  }
}
