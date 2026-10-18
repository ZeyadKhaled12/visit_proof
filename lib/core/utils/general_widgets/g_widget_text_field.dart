import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';

class GWidgetTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final String? errorMsg;
  final bool trimOuterSpaces;

  const GWidgetTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.errorMsg,
    this.trimOuterSpaces = true,
  });

  @override
  State<GWidgetTextField> createState() => _GWidgetTextFieldState();
}

class _GWidgetTextFieldState extends State<GWidgetTextField> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  bool get _shouldTrim => widget.trimOuterSpaces && !widget.obscureText;

  @override
  void initState() {
    super.initState();

    _internalController = TextEditingController(
      text: widget.initialValue?.trim() ?? '',
    );

    _internalFocusNode = FocusNode();

    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant GWidgetTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)
          .removeListener(_handleFocusChange);

      _effectiveFocusNode.addListener(_handleFocusChange);
    }

    if (oldWidget.controller != null && widget.controller == null) {
      _internalController.text = oldWidget.controller!.text;
    }
  }

  void _handleFocusChange() {
    if (!_effectiveFocusNode.hasFocus) {
      _trimSpaces();
    }
  }

  // Remove leading and trailing whitespace
  void _trimSpaces() {
    if (!_shouldTrim) return;

    final controller = _effectiveController;
    final trimmedText = controller.text.trim();

    if (controller.text != trimmedText) {
      controller.value = TextEditingValue(
        text: trimmedText,
        selection: TextSelection.collapsed(
          offset: trimmedText.length,
        ),
      );

      widget.onChanged?.call(trimmedText);
    }
  }

  // Prevent leading spaces while typing
  TextInputFormatter get _noLeadingSpacesFormatter =>
      TextInputFormatter.withFunction((oldValue, newValue) {
        final trimmedLeft = newValue.text.trimLeft();

        if (trimmedLeft == newValue.text) {
          return newValue;
        }

        final removedCount = newValue.text.length - trimmedLeft.length;

        int adjustOffset(int offset) {
          if (offset < 0) return offset;

          return (offset - removedCount).clamp(0, trimmedLeft.length);
        }

        return newValue.copyWith(
          text: trimmedLeft,
          selection: newValue.selection.copyWith(
            baseOffset: adjustOffset(newValue.selection.baseOffset),
            extentOffset: adjustOffset(newValue.selection.extentOffset),
          ),
          composing: TextRange.empty,
        );
      });

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);

    _internalFocusNode.dispose();
    _internalController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _effectiveController,
      focusNode: _effectiveFocusNode,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,

      // NEW: Trim when submitted
      onFieldSubmitted: (value) {
        _trimSpaces();
        widget.onFieldSubmitted?.call(
          _effectiveController.text,
        );
      },

      // NEW: Trim when saved
      onSaved: (value) {
        _trimSpaces();
        widget.onSaved?.call(
          _shouldTrim ? _effectiveController.text : value,
        );
      },

      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,

      // NEW: Block leading spaces
      inputFormatters: [
        if (_shouldTrim) _noLeadingSpacesFormatter,
        ...?widget.inputFormatters,
      ],

      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,

      style: AppFonts(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),

      cursorColor: AppColors.primary,

      decoration: InputDecoration(
          fillColor: AppColors.searchFieldBg,
          filled: true,
          hintText: widget.hintText,
          hintStyle: AppFonts(
            color: AppColors.textLightHint,
            fontSize: 14,
          ),
          labelText: widget.labelText,
          labelStyle: AppFonts(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          errorText: widget.errorMsg,
          errorStyle: AppFonts(
            color: AppColors.statOrange,
            fontSize: 12.9,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.iconLightGrey,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.statOrange,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.statOrange,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.iconLightGrey.withValues(
                alpha: 0.5,
              ),
              width: 1,
            ),
          ),
          counterText: ''),
    );
  }
}
