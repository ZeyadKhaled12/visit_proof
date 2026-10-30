import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import '../../../../../app/app.dart';
import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../domain/usecases/add_service_uc.dart';
import '../../controller/services_bloc.dart';

class AddServiceBody extends StatefulWidget {
  const AddServiceBody(
      {super.key,
      this.serviceModel,
      required this.categories,
      required this.loading,
      required this.getCategoriesLoading,
      this.blockSetLocal});
  final ServiceModel? serviceModel;
  final List<GModelCatg> categories;
  final bool getCategoriesLoading;
  final bool? blockSetLocal;
  final bool loading;

  @override
  State<AddServiceBody> createState() => _AddServiceBodyState();
}

class _AddServiceBodyState extends State<AddServiceBody> {
  final _serviceNameController = TextEditingController();
  final _priceController = TextEditingController(text: '25');
  final _durationController = TextEditingController(text: '60');
  final _newCategoryController = TextEditingController();
  final _checklistInputController = TextEditingController();

  GModelCatg? _selectedCategory;
  bool _isCreatingNewCategory = false;
  List<String> _checklistItems = [];

  String? _categoryErrorMsg;
  String? _categoryNameErrorMsg;
  String? _serviceNameError;
  String? _priceErrorMsg;
  String? _durationErrorMsg;

  @override
  void initState() {
    _serviceNameController.text = widget.serviceModel?.serviceName ?? '';
    _priceController.text = widget.serviceModel?.defaultPrice?.toString() ?? '';
    _selectedCategory = widget.serviceModel?.category;
    _checklistItems = List.from(widget.serviceModel?.checkList ?? []);
    super.initState();
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _priceController.dispose();
    _newCategoryController.dispose();
    _checklistInputController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addChecklistItem() {
    final text = _checklistInputController.text.trim();
    if (text.isNotEmpty && !_checklistItems.contains(text)) {
      setState(() {
        _checklistItems.add(text);
        _checklistInputController.clear();
      });
    }
  }

  void _removeChecklistItem(String item) {
    setState(() {
      _checklistItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dropdown Items
    List<DropdownMenuItem<GModelCatg>> dropdownItems =
        widget.categories.map((cat) {
      return DropdownMenuItem<GModelCatg>(
        value: cat,
        child: Text(cat.name ?? '', style: AppFonts()),
      );
    }).toList();

    // Option to create a new category
    dropdownItems.add(
      DropdownMenuItem<GModelCatg>(
        value: GModelCatg(name: 'CREATE_NEW'),
        child: Text(
          '+ Create New Category',
          style: AppFonts(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        // Padding handles keyboard overlap
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.locationChipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.serviceModel?.id != null
                        ? 'Update Service'
                        : 'Create New Service',
                    style: AppFonts(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Fill in the details below to add a service',
                    style: AppFonts(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 1. Category Selection
              GWidgetDropDown<GModelCatg>(
                items: dropdownItems,
                value: _selectedCategory,
                loading: widget.getCategoriesLoading,
                labelText: 'Category *',
                errorMsg: _categoryErrorMsg,
                prefixIcon: const Icon(Icons.category_outlined,
                    color: AppColors.primary),
                onChanged: (val) {
                  setState(() {
                    if (val?.name == 'CREATE_NEW') {
                      _isCreatingNewCategory = true;
                      _selectedCategory = val;
                    } else {
                      _isCreatingNewCategory = false;
                      _selectedCategory = val;
                    }
                  });
                },
              ),

              // Smoothly animate new category text field if selected
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isCreatingNewCategory
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GWidgetTextField(
                          controller: _newCategoryController,
                          labelText: 'New Category Name *',
                          hintText: 'e.g., HVAC',
                          errorMsg: _categoryNameErrorMsg,
                          prefixIcon: const Icon(
                              Icons.drive_file_rename_outline,
                              color: AppColors.primary),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // 2. Service Name
              GWidgetTextField(
                controller: _serviceNameController,
                labelText: 'Service Name *',
                hintText: 'e.g., Standard AC Tune-Up',
                errorMsg: _serviceNameError,
                prefixIcon: const Icon(Icons.miscellaneous_services_outlined,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 16),

              // 3. Price
              GWidgetTextField(
                  controller: _priceController,
                  labelText: 'Price *',
                  hintText: '0.00',
                  errorMsg: _priceErrorMsg,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: Text(App.currency,
                            style: AppFonts(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ))),
              const SizedBox(height: 16),

              // 3. Price
              GWidgetTextField(
                  controller: _durationController,
                  labelText: 'Duration *',
                  hintText: '60',
                  errorMsg: _durationErrorMsg,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  prefixIcon: SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: Text('Min',
                            style: AppFonts(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ))),
              const SizedBox(height: 24),

              // 4. Checklist (Optional)
              Text(
                'Service Checklist (Optional)',
                style: AppFonts(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GWidgetTextField(
                      controller: _checklistInputController,
                      hintText: 'Add task (e.g., Wash hair)',
                      prefixIcon: const Icon(Icons.check_box_outlined,
                          color: AppColors.secondary),
                      onFieldSubmitted: (_) => _addChecklistItem(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _addChecklistItem,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 56, // Matches GWidgetTextField default height
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Add',
                          style: AppFonts(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Display Checklist Items
              if (_checklistItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                Column(
                  spacing: 8,
                  children: _checklistItems.map((item) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.locationChipBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                AppColors.iconLightGrey.withValues(alpha: .3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  item,
                                  style: AppFonts(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _removeChecklistItem(item),
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.statOrange),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              GWidgetButton(
                  onPressed: () {
                    setState(() {
                      _categoryNameErrorMsg = null;
                      _categoryErrorMsg = null;
                      _serviceNameError = null;
                      _priceErrorMsg = null;
                      _durationErrorMsg = null;
                      if (_isCreatingNewCategory) {
                        if (_newCategoryController.text.isEmpty) {
                          _categoryNameErrorMsg = 'Category name is required';
                        } else if (_newCategoryController.text.length < 2) {
                          _categoryNameErrorMsg =
                              'Category name must be at least 2 characters long';
                        }
                      } else {
                        if (_selectedCategory == null) {
                          _categoryErrorMsg = 'Category is required';
                        }
                      }
                      if (_serviceNameController.text.isEmpty) {
                        _serviceNameError = 'Service name is required';
                      } else if (_serviceNameController.text.length < 2) {
                        _serviceNameError =
                            'Service name must be at least 2 characters long';
                      }
                      try {
                        if (double.parse(_priceController.text) < 0) {
                          _priceErrorMsg = 'Price must be grater than 0';
                        }
                      } catch (e) {
                        _priceErrorMsg = 'Price must be grater than 0';
                      }
                      try {
                        if (int.parse(_durationController.text) < 0) {
                          _durationErrorMsg =
                              'Duration must be grater than 0 minutes';
                        }
                      } catch (e) {
                        _durationErrorMsg =
                            'Duration must be grater than 0 minutes';
                      }
                    });
                    if (_categoryNameErrorMsg != null ||
                        _categoryErrorMsg != null ||
                        _serviceNameError != null ||
                        _priceErrorMsg != null ||
                        _durationErrorMsg != null) {
                      return;
                    }
                    context.read<ServicesBloc>().add(AddServiceEvent(
                        addServiceParameters: AddServiceParameters(
                            id: widget.serviceModel?.id,
                            serviceName: _serviceNameController.text,
                            category: _isCreatingNewCategory
                                ? null
                                : _selectedCategory,
                            categoryName: _isCreatingNewCategory
                                ? _newCategoryController.text
                                : null,
                            price: num.parse(_priceController.text),
                            duration: int.parse(_durationController.text),
                            checkList: _checklistItems,
                            blockSetLocal: widget.blockSetLocal ?? false)));
                  },
                  isLoading: widget.loading,
                  isEnable: !widget.getCategoriesLoading,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fabShadowColor,
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  text: widget.serviceModel?.id != null
                      ? 'Update Service'
                      : 'Save Service')
            ],
          ),
        ),
      ),
    );
  }
}
