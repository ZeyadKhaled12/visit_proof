import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';

class GWidgetPhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String initialCountryCode;
  final void Function(PhoneNumber phoneNumber)? onChanged;
  final void Function(PhoneNumber? phoneNumber)? onSaved;
  final void Function(String)? onSubmitted;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final FocusNode? focusNode;
  final String? errorMsg;
  final TextInputAction? textInputAction;

  const GWidgetPhoneField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.initialCountryCode = 'SA',
    this.onChanged,
    this.onSaved,
    this.onSubmitted,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
    this.errorMsg,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      focusNode: focusNode,
      initialCountryCode: initialCountryCode,
      readOnly: readOnly,
      autofocus: autofocus,
      enabled: enabled,
      textInputAction: textInputAction,      
      onChanged: onChanged,
      onSaved: onSaved,
      onSubmitted: onSubmitted,
      autovalidateMode: AutovalidateMode.disabled,
      // disableLengthCheck: true,
      // --- Relaxed & Creative Country Picker Dialog ---
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.number,
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor: AppColors.surfaceWhite,
        padding: const EdgeInsets.all(20),
        searchFieldPadding: const EdgeInsets.only(bottom: 16),
        // Soft divider between countries
        listTileDivider: const Divider(
          color: AppColors.locationChipBg,
          thickness: 1.5,
          height: 1.5,
        ),

        // Styling the country names
        countryNameStyle: AppFonts(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        // Adding a creative touch: making the country dial code your relaxing purple
        countryCodeStyle: AppFonts(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        searchFieldCursorColor: AppColors.primary,
        // Soft, borderless search field
        searchFieldInputDecoration: InputDecoration(
          fillColor: AppColors.locationChipBg,
          filled: true,
          hintText: 'Search country...',
          hintStyle: AppFonts(
            color: AppColors.textLightHint,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          // Relaxed, fully rounded corners with no harsh border lines
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          // Mint Cyan (secondary color) glows when the user taps to search
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide:
                const BorderSide(color: AppColors.secondary, width: 1.5),
          ),
        ),
      ),

      // Styling the input text
      style: AppFonts(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppColors.primary,

      // Styling the country code dropdown shown in the main UI
      dropdownTextStyle: AppFonts(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      dropdownIcon: const Icon(
        Icons.keyboard_arrow_down_rounded, // Slightly softer icon than default
        color: AppColors.textSecondary,
      ),

      // Your exact UI Decoration for the main text field
      decoration: InputDecoration(
        fillColor: AppColors.searchFieldBg,
        filled: true,
        hintText: hintText,
        hintStyle: AppFonts(color: AppColors.textLightHint, fontSize: 14),
        labelText: labelText,
        errorText: errorMsg,
        errorStyle: AppFonts(
            color: AppColors.statOrange,
            fontSize: 12.9,
            fontWeight: FontWeight.w500),
        labelStyle: AppFonts(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.iconLightGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.statOrange, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.statOrange, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: AppColors.iconLightGrey.withValues(alpha: 0.5), width: 1),
        ),
      ),
    );
  }
}
