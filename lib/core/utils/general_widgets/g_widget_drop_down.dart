import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import 'dart:math' as math;

class GWidgetDropDown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hintText;
  final String? labelText;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final bool isExpanded;
  final double iconSize;
  final String? errorMsg;
  final Widget? icon;

  // New properties
  final bool enableSearch;
  final double dropdownMaxHeight;
  final String searchHintText;
  final String emptyMessage;
  final String Function(DropdownMenuItem<T>)? searchTextBuilder;

  const GWidgetDropDown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.validator,
    this.errorMsg,
    this.prefixIcon,
    this.isExpanded = true,
    this.iconSize = 24.0,
    this.icon,

    // New parameters
    this.enableSearch = false,
    this.dropdownMaxHeight = 300,
    this.searchHintText = 'Search...',
    this.emptyMessage = 'No results found',
    this.searchTextBuilder,
  });

  @override
  State<GWidgetDropDown<T>> createState() => _GWidgetDropDownState<T>();
}

class _GWidgetDropDownState<T> extends State<GWidgetDropDown<T>> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  final GlobalKey<FormFieldState<T>> _formFieldKey = GlobalKey();

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  OverlayEntry? _overlayEntry;

  late T? _selectedValue;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();

    _selectedValue = widget.value;

    _searchController.addListener(_refreshOverlay);
  }

  @override
  void didUpdateWidget(covariant GWidgetDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _selectedValue = widget.value;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _formFieldKey.currentState?.didChange(_selectedValue);
        }
      });
    }

    if (oldWidget.items != widget.items ||
        oldWidget.enableSearch != widget.enableSearch ||
        oldWidget.dropdownMaxHeight != widget.dropdownMaxHeight) {
      _refreshOverlay();
    }
  }

  void _refreshOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  String _getSearchText(DropdownMenuItem<T> item) {
    if (widget.searchTextBuilder != null) {
      return widget.searchTextBuilder!(item);
    }

    if (item.child is Text) {
      final text = item.child as Text;
      return text.data ?? text.textSpan?.toPlainText() ?? '';
    }

    return item.value?.toString() ?? '';
  }

  List<DropdownMenuItem<T>> get _filteredItems {
    if (!widget.enableSearch) {
      return widget.items;
    }

    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.items;
    }

    return widget.items.where((item) {
      return _getSearchText(item).toLowerCase().contains(query);
    }).toList();
  }

  void _toggleDropdown() {
    if (widget.onChanged == null) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;

    final fieldContext = _fieldKey.currentContext;
    if (fieldContext == null) return;

    final renderBox = fieldContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    _searchController.clear();

    final overlay = Overlay.of(context, rootOverlay: true);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final currentBox =
            _fieldKey.currentContext?.findRenderObject() as RenderBox?;

        if (currentBox == null || !currentBox.hasSize) {
          return const SizedBox.shrink();
        }

        final overlayBox = overlay.context.findRenderObject() as RenderBox;

        final fieldSize = currentBox.size;

        final fieldBottom = overlayBox
            .globalToLocal(
              currentBox.localToGlobal(
                Offset(0, fieldSize.height),
              ),
            )
            .dy;

        final mediaQuery = MediaQuery.of(overlayContext);

        // Only use the space BELOW the dropdown.
        final availableHeight = math.max(
          0.0,
          overlayBox.size.height -
              fieldBottom -
              mediaQuery.viewInsets.bottom -
              mediaQuery.padding.bottom -
              8,
        );

        final menuHeight = math.min(
          widget.dropdownMaxHeight,
          availableHeight,
        );

        return Stack(
          children: [
            // Close dropdown when tapping outside.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
                child: const SizedBox.expand(),
              ),
            ),

            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 4),
              child: SizedBox(
                width: fieldSize.width,
                child: Material(
                  color: AppColors.surfaceWhite,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: math.max(0, menuHeight - 4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.iconLightGrey,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.enableSearch)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              autofocus: false,
                              style: AppFonts(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: widget.searchHintText,
                                hintStyle: AppFonts(
                                  color: AppColors.textLightHint,
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: AppColors.searchFieldBg,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        Flexible(
                          child: _filteredItems.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      widget.emptyMessage,
                                      style: AppFonts(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: _filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredItems[index];

                                    final isSelected =
                                        item.value == _selectedValue;

                                    return InkWell(
                                      onTap: item.enabled
                                          ? () => _selectItem(item.value)
                                          : null,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minHeight: 48,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        color: isSelected
                                            ? AppColors.primary
                                                .withValues(alpha: .08)
                                            : Colors.transparent,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: DefaultTextStyle(
                                                style: AppFonts(
                                                  color: item.enabled
                                                      ? AppColors.textPrimary
                                                      : AppColors.textSecondary,
                                                  fontSize: 15,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                ),
                                                child: item.child,
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_rounded,
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);

    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;

    _searchFocusNode.unfocus();

    if (mounted && _isOpen) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _selectItem(T? selectedValue) {
    setState(() {
      _selectedValue = selectedValue;
    });

    _formFieldKey.currentState?.didChange(selectedValue);

    _closeDropdown();

    widget.onChanged?.call(selectedValue);
  }

  Widget? _getSelectedChild() {
    for (final item in widget.items) {
      if (item.value == _selectedValue) {
        return item.child;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _fieldKey,
        child: FormField<T>(
          key: _formFieldKey,
          initialValue: _selectedValue,
          validator: widget.validator,
          builder: (field) {
            final selectedChild = _getSelectedChild();
            final hasValue = selectedChild != null;

            return InkWell(
              onTap: widget.onChanged != null ? _toggleDropdown : null,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                isEmpty: !hasValue,
                isFocused: _isOpen,
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
                  errorText: widget.errorMsg ?? field.errorText,
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
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    if (hasValue)
                      Flexible(
                        child: DefaultTextStyle(
                          style: AppFonts(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: selectedChild,
                        ),
                      )
                    else
                      Expanded(
                        child: Text(
                          widget.hintText ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts(
                            color: AppColors.textLightHint,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    widget.icon ??
                        Icon(
                          _isOpen
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: widget.iconSize,
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();

    _searchController.removeListener(_refreshOverlay);
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }
}
