import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../configs/app_toasts.dart';
import '../../../../../core/utils/general_dummy_data.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_valid.dart';
import '../../../../../core/utils/general_models/g_model_catg.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_card_title.dart';
import '../../../../../core/utils/general_widgets/g_widget_check_whatsapp.dart';
import '../../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../../../../core/utils/general_widgets/g_widget_phone_field.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../data/models/client_detail_model/client_detail_model.dart';
import '../../../domain/usecases/add_client_uc.dart';
import '../../controller/clients_bloc.dart';
import 'add_client_widget_location.dart';

class AddClientBody extends StatefulWidget {
  const AddClientBody(
      {super.key, required this.loading, this.clientDetailModel});
  final bool loading;
  final ClientDetailModel? clientDetailModel;

  @override
  State<AddClientBody> createState() => _AddClientBodyState();
}

class _AddClientBodyState extends State<AddClientBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber? _phoneNumber;
  LatLng? _location;

  GModelCatg? _selectedCity;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _nameErrorMsg;
  String? _emailErrorMsg;
  String? _phoneErrorMsg;
  String? _cityErrorMsg;
  String? _addressErrorMsg;

  bool _hasWhatsapp = false;

  List<GModelCatg> _cities = [];

  @override
  void initState() {
    _getCities();
    if (widget.clientDetailModel?.id != null) {
      _setClientDataUpdate();
    }
    super.initState();
  }

  void _setClientDataUpdate() {
    setState(() {
      _nameController.text = widget.clientDetailModel?.name ?? '';
      _emailController.text = widget.clientDetailModel?.email ?? '';

      _phoneNumber = PhoneNumber.fromCompleteNumber(
          completeNumber: widget.clientDetailModel?.phone ?? '');
      _hasWhatsapp = widget.clientDetailModel?.isWhatsAppPhone ?? false;
      _selectedCity = widget.clientDetailModel?.site?.city;
      _addressController.text =
          widget.clientDetailModel?.site?.addressDetail ?? '';
      if (widget.clientDetailModel?.site?.latitude != null &&
          widget.clientDetailModel?.site?.longitude != null) {
        _location = LatLng(widget.clientDetailModel!.site!.latitude!,
            widget.clientDetailModel!.site!.longitude!);
      }
      _phoneController.text = _phoneNumber?.number ?? '';
      _notesController.text = widget.clientDetailModel?.notes ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _getCities() {
    _cities = GeneralDummyData.getSaudiCities();
  }

  @override
  Widget build(BuildContext context) {
    return GWidgetNaviBody(
        title: widget.clientDetailModel?.id != null
            ? 'Edit Client'
            : 'Add New Client',
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              GWidgetCardTitle(
                  icon: Icons.person_pin,
                  title: 'Personal Info',
                  child: Column(
                    children: [
                      GWidgetTextField(
                        controller: _nameController,
                        labelText: 'Full Name *',
                        hintText: 'e.g. Zeyad Khaled',
                        maxLength: 100,
                        errorMsg: _nameErrorMsg,
                        prefixIcon: Icon(Icons.person_outline,
                            color: AppTheme.primary),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      GWidgetTextField(
                        controller: _emailController,
                        labelText: 'Email Address (Optional)',
                        hintText: 'client@example.com',
                        errorMsg: _emailErrorMsg,
                        maxLength: 254,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.alternate_email,
                            color: AppTheme.primary),
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  )),
              const SizedBox(height: 32),
              GWidgetCardTitle(
                  icon: Icons.contact_phone_outlined,
                  title: 'Contact Info',
                  child: Column(
                    children: [
                      GWidgetPhoneField(
                        initialCountryCode:
                            _phoneNumber?.countryISOCode ?? 'SA',
                        controller: _phoneController,
                        labelText: 'Phone Number *',
                        hintText: 'XXX XXXX XXXX',
                        errorMsg: _phoneErrorMsg,
                        onChanged: (phoneNumber) {
                          setState(() {
                            _phoneNumber = phoneNumber;
                          });
                        },
                        onSaved: (phoneNumber) {
                          setState(() {
                            _phoneNumber = phoneNumber;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      GWidgetCheckWhatsapp(
                          onPressed: () {
                            setState(() {
                              _hasWhatsapp = !_hasWhatsapp;
                            });
                            HapticFeedback.lightImpact();
                          },
                          hasWhatsapp: _hasWhatsapp)
                    ],
                  )),
              const SizedBox(height: 32),
              GWidgetCardTitle(
                  icon: Icons.map_outlined,
                  title: 'Location Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GWidgetDropDown<GModelCatg>(
                        value: _selectedCity,
                        enableSearch: true,
                        labelText: 'Select City *',
                        errorMsg: _cityErrorMsg,
                        prefixIcon: Icon(Icons.location_city,
                            color: AppTheme.primary),
                        items: _cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city.name ?? '',
                                style: AppTheme.font(fontWeight: FontWeight.w500)),
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
                        style: AppTheme.font(
                          color: AppTheme.textPrimary.withValues(alpha: 0.8),
                          fontSize: AppTheme.textBodyLarge,
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
                      )
                    ],
                  )),
              const SizedBox(height: 32),
              GWidgetCardTitle(
                  icon: Icons.note_alt_outlined,
                  title: 'Extra Info',
                  child: GWidgetTextField(
                    controller: _notesController,
                    maxLength: 1000,
                    labelText: 'Notes (Optional)',
                    hintText: 'Any special requests or details...',
                    maxLines: 4,
                    prefixIcon:
                        Icon(Icons.edit_note, color: AppTheme.textNotes),
                  )),
              const SizedBox(height: 40),
              GWidgetButton(
                onPressed: () {
                  setState(() {
                    _nameErrorMsg = null;
                    _emailErrorMsg = null;
                    _phoneErrorMsg = null;
                    _cityErrorMsg = null;
                    _addressErrorMsg = null;
                  });
                  if (_nameController.text.isEmpty &&
                      _phoneController.text.isEmpty &&
                      _selectedCity == null) {
                    AppToasts.showMessage(
                        'Please fill in all fields marked with an asterisk (*).',
                        isError: true);
                    setState(() {
                      _nameErrorMsg = _nameController.text.isEmpty ? '' : null;
                      _phoneErrorMsg =
                          _phoneController.text.isEmpty ? '' : null;
                      _cityErrorMsg = _selectedCity == null ? '' : null;
                    });
                    return;
                  }

                  if (_nameController.text.length < 2) {
                    AppToasts.showMessage(
                        'Name must be at least 2 characters long',
                        isError: true);
                    setState(() {
                      _nameErrorMsg = '';
                    });
                    return;
                  }

                  if (_emailController.text.isNotEmpty &&
                      !GFunValid.isValidEmail(_emailController.text)) {
                    AppToasts.showMessage('Please enter a valid email address',
                        isError: true);
                    setState(() {
                      _emailErrorMsg = '';
                    });
                    return;
                  }

                  if (!GFunValid.isValidPhoneNumber(_phoneNumber)) {
                    AppToasts.showMessage('Invalid phone number',
                        isError: true);
                    setState(() {
                      _phoneErrorMsg = '';
                    });
                    return;
                  }

                  if (_selectedCity == null) {
                    AppToasts.showMessage('City is required', isError: true);
                    setState(() {
                      _cityErrorMsg = '';
                    });
                    return;
                  }

                  if (_location == null && _addressController.text.isEmpty) {
                    AppToasts.showMessage(
                        'Please provide an address detail or pick a location from the map.',
                        isError: true);
                    setState(() {
                      _addressErrorMsg = '';
                    });
                    return;
                  }

                  if (_location == null &&
                      (_addressController.text.length < 10 &&
                          _addressController.text.isNotEmpty)) {
                    AppToasts.showMessage(
                        'Detailed address must be at least 10 characters long',
                        isError: true);
                    setState(() {
                      _addressErrorMsg = '';
                    });
                    return;
                  }
                  if (_nameErrorMsg != null ||
                      _emailErrorMsg != null ||
                      _phoneErrorMsg != null ||
                      _cityErrorMsg != null ||
                      _addressErrorMsg != null) {
                    return;
                  }

                  context.read<ClientsBloc>().add(AddClientEvent(
                          addClientParameters: AddClientParameters(
                        id: widget.clientDetailModel?.id,
                        name: _nameController.text,
                        email: _emailController.text.isEmpty
                            ? null
                            : _emailController.text,
                        phoneNumber:
                            _phoneNumber!.completeNumber.startsWith('+')
                                ? _phoneNumber!.completeNumber
                                : '+${_phoneNumber!.completeNumber}',
                        whatsAppNumber: _hasWhatsapp,
                        city: _selectedCity!,
                        latitude: _location?.latitude,
                        longitude: _location?.longitude,
                        notes: _notesController.text.isEmpty
                            ? ''
                            : _notesController.text,
                        addressDetail: _addressController.text.isEmpty
                            ? ''
                            : _addressController.text,
                      )));
                },
                text: widget.clientDetailModel?.id != null
                    ? 'Update Client'
                    : 'Save Client',
                height: 60,
                isLoading: widget.loading,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.fabShadowColor,
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }
}
