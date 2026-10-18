import 'package:flutter/material.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_phone_field.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_text_field.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/utils/general_models/g_model_catg.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';

final List<GModelCatg> availableCategories = [
  GModelCatg(id: '1', name: 'HVAC Specialist'),
  GModelCatg(id: '2', name: 'Plumber'),
  GModelCatg(id: '3', name: 'Electrician'),
  GModelCatg(id: '4', name: 'Appliance Repair'),
  GModelCatg(id: '5', name: 'Carpenter'),
];

class AddTechWidgetSheet extends StatefulWidget {
  const AddTechWidgetSheet({super.key});

  @override
  State<AddTechWidgetSheet> createState() => _AddTechWidgetSheetState();
}

class _AddTechWidgetSheetState extends State<AddTechWidgetSheet> {
  bool _isPasswordHidden = true;
  final List<GModelCatg> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add New Technician',
                        style: AppFonts(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.locationChipBg,
                          child: const Icon(Icons.close,
                              size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Text Fields ---
                  GWidgetTextField(
                    hintText: 'Full Name *',
                    prefixIcon: Icon(Icons.person_outline,
                        color: AppColors.primary, size: 20),
                  ),

                  const SizedBox(height: 12),
                  GWidgetPhoneField(
                    hintText: 'Phone Number *',
                  ),

                  const SizedBox(height: 12),
                  GWidgetTextField(
                    hintText: 'Email Address *',
                    prefixIcon: Icon(Icons.email_outlined,
                        color: AppColors.primary, size: 20),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 12),
                  GWidgetTextField(
                    hintText: 'Password *',
                    obscureText: _isPasswordHidden,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Categories Section ---
                  Text(
                    'Specializations (Categories)',
                    style: AppFonts(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableCategories.map((catg) {
                      final isSelected = _selectedCategories.contains(catg);
                      return FilterChip(
                        label: Text(
                          catg.name ?? 'Unknown',
                          style: AppFonts(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: isSelected,
                        selectedColor: AppColors.secondary,
                        backgroundColor: AppColors.surfaceWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.locationChipBg,
                          ),
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(catg);
                            } else {
                              _selectedCategories.remove(catg);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  GWidgetButton(
                    text: 'Add Technician',
                    width: double.infinity,
                    height: 48,
                    raduis: 14,
                    backgroundColor: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
