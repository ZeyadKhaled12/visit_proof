import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import '../../../../../app/app.dart';
import '../../../../../configs/app_theme.dart';
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
        child: Text((cat.name ?? '').tr, style: AppTheme.font()),
      );
    }).toList();

    // Option to create a new category
    dropdownItems.add(
      DropdownMenuItem<GModelCatg>(
        value: GModelCatg(name: 'CREATE_NEW'),
        child: Text(
          '+ Create New Category'.tr,
          style: AppTheme.font(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
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
                    color: AppTheme.locationChipBg,
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
                        ? 'Update Service'.tr
                        : 'Create New Service'.tr,
                    style: AppTheme.font(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.textHeadline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Fill in the details below to add a service'.tr,
                    style: AppTheme.font(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.textBody,
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
                labelText: 'Category *'.tr,
                errorMsg: _categoryErrorMsg,
                prefixIcon: Icon(Icons.category_outlined,
                    color: AppTheme.primary),
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
                          labelText: 'New Category Name *'.tr,
                          hintText: 'e.g., HVAC'.tr,
                          errorMsg: _categoryNameErrorMsg,
                          prefixIcon: Icon(
                              Icons.drive_file_rename_outline,
                              color: AppTheme.primary),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // 2. Service Name
              GWidgetTextField(
                controller: _serviceNameController,
                labelText: 'Service Name *'.tr,
                hintText: 'e.g., Standard AC Tune-Up'.tr,
                errorMsg: _serviceNameError,
                prefixIcon: Icon(Icons.miscellaneous_services_outlined,
                    color: AppTheme.primary),
              ),
              const SizedBox(height: 16),

              // 3. Price
              GWidgetTextField(
                  controller: _priceController,
                  labelText: 'Price *'.tr,
                  hintText: '0.00',
                  errorMsg: _priceErrorMsg,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: Text(App.currency,
                            style: AppTheme.font(
                                fontSize: AppTheme.textSmall,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary)),
                      ))),
              const SizedBox(height: 16),

              // 3. Price
              GWidgetTextField(
                  controller: _durationController,
                  labelText: 'Duration *'.tr,
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
                        child: Text('Min'.tr,
                            style: AppTheme.font(
                                fontSize: AppTheme.textSmall,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary)),
                      ))),
              const SizedBox(height: 24),

              // 4. Checklist (Optional)
              Text(
                'Service Checklist (Optional)'.tr,
                style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textBodyLarge,
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
                      hintText: 'Add task (e.g., Wash hair)'.tr,
                      prefixIcon: Icon(Icons.check_box_outlined,
                          color: AppTheme.secondary),
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
                        color: AppTheme.secondary.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Add'.tr,
                          style: AppTheme.font(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.textSubtitle,
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
                        color: AppTheme.locationChipBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                AppTheme.iconLightGrey.withValues(alpha: .3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    size: 16, color: AppTheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  item,
                                  style: AppTheme.font(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppTheme.textBody,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _removeChecklistItem(item),
                            child: Icon(Icons.close_rounded,
                                size: 18, color: AppTheme.statOrange),
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
                          _categoryNameErrorMsg = 'Category name is required'.tr;
                        } else if (_newCategoryController.text.length < 2) {
                          _categoryNameErrorMsg =
                              'Category name must be at least 2 characters long'.tr;
                        }
                      } else {
                        if (_selectedCategory == null) {
                          _categoryErrorMsg = 'Category is required'.tr;
                        }
                      }
                      if (_serviceNameController.text.isEmpty) {
                        _serviceNameError = 'Service name is required'.tr;
                      } else if (_serviceNameController.text.length < 2) {
                        _serviceNameError =
                            'Service name must be at least 2 characters long'.tr;
                      }
                      try {
                        if (double.parse(_priceController.text) < 0) {
                          _priceErrorMsg = 'Price must be grater than 0'.tr;
                        }
                      } catch (e) {
                        _priceErrorMsg = 'Price must be grater than 0'.tr;
                      }
                      try {
                        if (int.parse(_durationController.text) < 0) {
                          _durationErrorMsg =
                              'Duration must be grater than 0 minutes'.tr;
                        }
                      } catch (e) {
                        _durationErrorMsg =
                            'Duration must be grater than 0 minutes'.tr;
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
                      color: AppTheme.fabShadowColor,
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  text: widget.serviceModel?.id != null
                      ? 'Update Service'.tr
                      : 'Save Service'.tr)
            ],
          ),
        ),
      ),
    );
  }
}
