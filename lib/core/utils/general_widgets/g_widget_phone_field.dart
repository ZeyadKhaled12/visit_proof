import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../configs/app_theme.dart';
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
    // Phone numbers read left-to-right in Arabic too.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: IntlPhoneField(
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
        // Country names and the error follow the app language.
        languageCode: AppLanguage.locale.languageCode,
        invalidNumberMessage: 'Invalid phone number'.tr,
        // disableLengthCheck: true,
        // --- Relaxed & Creative Country Picker Dialog ---
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        keyboardType: TextInputType.number,
        pickerDialogStyle: PickerDialogStyle(
          backgroundColor: AppTheme.surface,
          padding: const EdgeInsets.all(20),
          searchFieldPadding: const EdgeInsets.only(bottom: 16),
          // Soft divider between countries
          listTileDivider: Divider(
            color: AppTheme.locationChipBg,
            thickness: 1.5,
            height: 1.5,
          ),

          // Styling the country names
          countryNameStyle: AppTheme.font(
            color: AppTheme.textPrimary,
            fontSize: AppTheme.textTitle,
            fontWeight: FontWeight.w600,
          ),
          // Adding a creative touch: making the country dial code your relaxing purple
          countryCodeStyle: AppTheme.font(
            color: AppTheme.primary,
            fontSize: AppTheme.textBodyLarge,
            fontWeight: FontWeight.bold,
          ),
          searchFieldCursorColor: AppTheme.primary,
          // Soft, borderless search field
          searchFieldInputDecoration: InputDecoration(
            fillColor: AppTheme.locationChipBg,
            filled: true,
            hintText: 'Search country...'.tr,
            hintStyle: AppTheme.font(
              color: AppTheme.textLightHint,
              fontSize: AppTheme.textBodyLarge,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.primary,
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
                  BorderSide(color: AppTheme.secondary, width: 1.5),
            ),
          ),
        ),

        // Styling the input text
        style: AppTheme.font(
          color: AppTheme.textPrimary,
          fontSize: AppTheme.textTitle,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppTheme.primary,

        // Styling the country code dropdown shown in the main UI
        dropdownTextStyle: AppTheme.font(
          color: AppTheme.textPrimary,
          fontSize: AppTheme.textTitle,
          fontWeight: FontWeight.w500,
        ),
        dropdownIcon: Icon(
          Icons.keyboard_arrow_down_rounded, // Slightly softer icon than default
          color: AppTheme.textSecondary,
        ),

        // Your exact UI Decoration for the main text field
        decoration: InputDecoration(
          fillColor: AppTheme.searchFieldBg,
          filled: true,
          hintText: hintText,
          hintStyle: AppTheme.font(color: AppTheme.textLightHint, fontSize: AppTheme.textBodyLarge),
          labelText: labelText,
          errorText: errorMsg,
          errorStyle: AppTheme.font(
              color: AppTheme.statOrange,
              fontSize: AppTheme.textSmall,
              fontWeight: FontWeight.w500),
          labelStyle: AppTheme.font(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.textBodyLarge,
              fontWeight: FontWeight.w600),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: AppTheme.iconLightGrey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.statOrange, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.statOrange, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: AppTheme.iconLightGrey.withValues(alpha: 0.5), width: 1),
          ),
        ),
      ),
    );
  }
}
