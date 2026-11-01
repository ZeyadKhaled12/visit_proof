import 'package:visit_proof/configs/app_language.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/features/technicians/domain/usecases/add_tech_uc.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';
import '../../../../../configs/app_theme.dart';
import '../../../../../configs/app_toasts.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_valid.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../../../../core/utils/general_widgets/g_widget_phone_field.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../data/models/technician_detail_model.dart';
import 'add_tech_widget_categories.dart';

class AddTechBody extends StatefulWidget {
  const AddTechBody(
      {super.key,
      this.technicianDetailModel,
      required this.loading,
      required this.categories,
      required this.categoriesLoading});
  final TechnicianDetailModel? technicianDetailModel;
  final List<GModelCatg> categories;
  final bool categoriesLoading;
  final bool loading;

  @override
  State<AddTechBody> createState() => _AddTechBodyState();
}

class _AddTechBodyState extends State<AddTechBody> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  PhoneNumber? _phoneNumber;

  bool _isPasswordVisible = false;

  //errors msgs
  String? _nameErrorMsg;
  String? _phoneErrorMsg;
  String? _emailErrorMsg;
  String? _passwordErrorMsg;
  bool _categoriesError = false;

  // Store selected categories (Allows multiple selections)
  Set<GModelCatg> _selectedCategories = {};

  @override
  void initState() {
    _nameController.text = widget.technicianDetailModel?.name ?? '';
    _phoneNumber = PhoneNumber.fromCompleteNumber(
        completeNumber: widget.technicianDetailModel?.phone ?? '');
    _phoneController.text = _phoneNumber?.number ?? '';
    _emailController.text = widget.technicianDetailModel?.email ?? '';
    _selectedCategories =
        Set.from(widget.technicianDetailModel?.categories ?? []);

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('Password: ${widget.technicianDetailModel?.password}');
    return GWidgetNaviBody(
      title: 'Add Technician'.tr,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GWidgetTextField(
                controller: _nameController,
                labelText: 'Full Name *'.tr,
                hintText: 'e.g. Zeyad Khaled'.tr,
                maxLength: 100,
                errorMsg: _nameErrorMsg,
                prefixIcon:
                    Icon(Icons.person_outline, color: AppTheme.primary),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              GWidgetPhoneField(
                initialCountryCode: _phoneNumber?.countryISOCode ?? 'SA',
                controller: _phoneController,
                labelText: 'Phone Number *'.tr,
                hintText: 'XXX XXXX XXXX'.tr,
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
              GWidgetTextField(
                controller: _emailController,
                labelText: 'Email Address *'.tr,
                hintText: 'technician@example.com'.tr,
                errorMsg: _emailErrorMsg,
                maxLength: 254,
                keyboardType: TextInputType.emailAddress,
                prefixIcon:
                    Icon(Icons.alternate_email, color: AppTheme.primary),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              GWidgetTextField(
                controller: _passwordController,
                labelText: 'Password *'.tr,
                hintText: '••••••••••••',
                errorMsg: _passwordErrorMsg,
                obscureText: _isPasswordVisible,
                maxLength: 254,
                keyboardType: TextInputType.emailAddress,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.iconGrey,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                prefixIcon:
                    Icon(Icons.lock_outline, color: AppTheme.primary),
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 24),

              // Categories Section (Multi-select)
              AddTechWidgetCategories(
                  selectedCategories: _selectedCategories,
                  categories: widget.categories,
                  categoriesLoading: widget.categoriesLoading,
                  isError: _categoriesError,
                  onRemove: (category) {
                    setState(() {
                      _selectedCategories.remove(category);
                    });
                  },
                  onAdd: (category) {
                    setState(() {
                      _selectedCategories.add(category);
                    });
                  }),

              const SizedBox(height: 40),

              // Submit Button
              GWidgetButton(
                isLoading: widget.loading,
                onPressed: () {
                  setState(() {
                    _nameErrorMsg = null;
                    _emailErrorMsg = null;
                    _phoneErrorMsg = null;
                    _passwordErrorMsg = null;
                    _categoriesError = false;
                  });
                  if (_nameController.text.isEmpty &&
                      _emailController.text.isEmpty &&
                      _phoneController.text.isEmpty &&
                      _passwordController.text.isEmpty) {
                    AppToasts.showMessage(
                        'Please fill in all fields marked with an asterisk (*).'.tr,
                        isError: true);
                    setState(() {
                      _nameErrorMsg = '';
                      _emailErrorMsg = '';
                      _phoneErrorMsg = '';
                      _passwordErrorMsg = '';
                      _categoriesError = true;
                    });
                    return;
                  }

                  if (_nameController.text.length < 2) {
                    AppToasts.showMessage(
                        'Name must be at least 2 characters long'.tr,
                        isError: true);
                    setState(() {
                      _nameErrorMsg = '';
                    });
                    return;
                  }

                  if (!GFunValid.isValidPhoneNumber(_phoneNumber)) {
                    AppToasts.showMessage('Invalid phone number'.tr,
                        isError: true);
                    setState(() {
                      _phoneErrorMsg = '';
                    });
                    return;
                  }

                  if (!GFunValid.isValidEmail(_emailController.text)) {
                    AppToasts.showMessage('Please enter a valid email address'.tr,
                        isError: true);
                    setState(() {
                      _emailErrorMsg = '';
                    });
                    return;
                  }
                  if (widget.technicianDetailModel?.id != null &&
                          _passwordController.text.isNotEmpty ||
                      (widget.technicianDetailModel?.id == null)) {
                    if (!GFunValid.isStrongPassword(_passwordController.text)) {
                      AppToasts.showMessage(
                          'Your password is not strong enough. Use 8+ characters with uppercase, lowercase, number & symbol.'.tr,
                          isError: true);
                      setState(() {
                        _passwordErrorMsg = '';
                      });
                      return;
                    }
                  }

                  if (_selectedCategories.isEmpty) {
                    AppToasts.showMessage('Please enter at least one category'.tr,
                        isError: true);
                    setState(() {
                      _categoriesError = true;
                    });
                    return;
                  }

                  if (_nameErrorMsg != null ||
                      _emailErrorMsg != null ||
                      _phoneErrorMsg != null ||
                      _passwordErrorMsg != null ||
                      _categoriesError) {
                    return;
                  }
                  context.read<TechBloc>().add(AddTechEvent(
                      addTechParameters: AddTechParameters(
                          id: widget.technicianDetailModel?.id,
                          name: _nameController.text,
                          phoneNumber:
                              _phoneNumber!.completeNumber.startsWith('+')
                                  ? _phoneNumber!.completeNumber
                                  : '+${_phoneNumber!.completeNumber}',
                          email: _emailController.text,
                          password: _passwordController.text.isEmpty
                              ? null
                              : _passwordController.text,
                          categories: _selectedCategories.toList())));
                },
                text: widget.technicianDetailModel?.id != null
                    ? 'Update Technician'.tr
                    : 'Create Technician'.tr,
                height: 60,
                // isLoading: widget.loading,
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
        ),
      ),
    );
  }
}
