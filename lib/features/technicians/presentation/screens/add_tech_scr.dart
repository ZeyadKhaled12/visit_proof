import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_toasts.dart';
import '../../../../core/utils/general_functions.dart/g_fun_valid.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../../../core/utils/general_widgets/g_widget_phone_field.dart';
import '../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../widgets/add_technician_widgets/add_tech_widget_categories.dart';

// --- SCREEN IMPLEMENTATION ---

//name length from 2 to 100
//phone format
//email format
//Password format
//categories can't be empty

class AddTechScr extends StatefulWidget {
  const AddTechScr({super.key});
  static const route = '/AddTechScr';

  @override
  State<AddTechScr> createState() => _AddTechScrState();
}

class _AddTechScrState extends State<AddTechScr> {
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
  final Set<String> _selectedCategories = {};

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
    return GWidgetNaviBody(
      title: 'Add Technician',
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GWidgetTextField(
                controller: _nameController,
                labelText: 'Full Name *',
                hintText: 'e.g. Zeyad Khaled',
                maxLength: 100,
                errorMsg: _nameErrorMsg,
                prefixIcon:
                    const Icon(Icons.person_outline, color: AppColors.primary),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              GWidgetPhoneField(
                initialCountryCode: _phoneNumber?.countryISOCode ?? 'SA',
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
              GWidgetTextField(
                controller: _emailController,
                labelText: 'Email Address *',
                hintText: 'technician@example.com',
                errorMsg: _emailErrorMsg,
                maxLength: 254,
                keyboardType: TextInputType.emailAddress,
                prefixIcon:
                    const Icon(Icons.alternate_email, color: AppColors.primary),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              GWidgetTextField(
                controller: _passwordController,
                labelText: 'Password *',
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
                    color: AppColors.iconGrey,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                prefixIcon:
                    const Icon(Icons.lock_outline, color: AppColors.primary),
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 24),

              // Categories Section (Multi-select)
              AddTechWidgetCategories(
                  selectedCategories: _selectedCategories,
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
                        'Please fill in all fields marked with an asterisk (*).',
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
                        'Name must be at least 2 characters long',
                        isError: true);
                    setState(() {
                      _nameErrorMsg = '';
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

                  if (!GFunValid.isValidEmail(_emailController.text)) {
                    AppToasts.showMessage('Please enter a valid email address',
                        isError: true);
                    setState(() {
                      _emailErrorMsg = '';
                    });
                    return;
                  }
                  if (!GFunValid.isStrongPassword(_passwordController.text)) {
                    AppToasts.showMessage(
                        'Your password is not strong enough. Use 8+ characters with uppercase, lowercase, number & symbol.',
                        isError: true);
                    setState(() {
                      _passwordErrorMsg = '';
                    });
                    return;
                  }
                  if (_selectedCategories.isEmpty) {
                    AppToasts.showMessage('Please enter at least one category',
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
                      !_categoriesError) {
                    return;
                  }
                },
                text: 'Create Technician',
                height: 60,
                // isLoading: widget.loading,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fabShadowColor,
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
