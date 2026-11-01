import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_date_pick.dart';
import '../../../../core/utils/general_widgets/g_widget_add_btn.dart';
import '../../../../core/utils/general_widgets/g_widget_card_title.dart';
import '../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../technicians/data/models/technician_detail_model.dart';
import '../../../technicians/data/models/technician_model.dart';
import 'package:intl/intl.dart';
import '../../../technicians/presentation/screens/add_tech_scr.dart';

class AddVisitWidgetSchedule extends StatelessWidget {
  const AddVisitWidgetSchedule(
      {super.key,
      this.selectedPriority,
      this.selectedTechnician,
      this.startDate,
      this.startTime,
      this.startDateErrorMsg,
      this.startTimeErrorMsg,
      required this.onTechnicianChanged,
      required this.onPriorityChanged,
      required this.onStartDatePicked,
      required this.onStartTimeChanged,
      required this.problem,
      required this.notes,
      required this.technicians,
      required this.techniciansLoading});
  final List<TechnicianModel> technicians;
  final bool techniciansLoading;
  final Priority? selectedPriority;
  final TechnicianModel? selectedTechnician;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final TextEditingController problem;
  final TextEditingController notes;
  final String? startDateErrorMsg;
  final String? startTimeErrorMsg;
  final Function(TechnicianModel? technician, {bool? isNew})
      onTechnicianChanged;
  final Function(Priority? priority) onPriorityChanged;
  final Function(DateTime startDate) onStartDatePicked;
  final Function(TimeOfDay startTime) onStartTimeChanged;

  @override
  Widget build(BuildContext context) {
    return GWidgetCardTitle(
        icon: Icons.assignment,
        title: 'Scheduling & Assignment'.tr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GWidgetDropDown<TechnicianModel>(
              labelText: 'Technician'.tr,
              searchHintText: 'Search for an technician'.tr,
              loading: techniciansLoading,
              enableSearch: true,
              value: selectedTechnician,
              onChanged: onTechnicianChanged,
              items: technicians.map((technician) {
                return DropdownMenuItem(
                  value: technician,
                  child: Text(technician.name ?? '',
                      style: AppTheme.font(fontWeight: FontWeight.w500)),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            GWidgetAddBtn(
                text: 'Add New Technician'.tr,
                onTap: () async {
                  final data =
                      await Navigator.pushNamed(context, AddTechScr.route);
                  if (data is TechnicianDetailModel) {
                    onTechnicianChanged(data.convertToTechnicianModel(),
                        isNew: true);
                  }
                }),
            SizedBox(height: 16),
            GWidgetDropDown<Priority>(
              labelText: 'Priority'.tr,
              value: selectedPriority,
              onChanged: onPriorityChanged,
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(PrioritySwitch(priorityEnum: priority).getText(),
                      style: AppTheme.font(fontWeight: FontWeight.w500)),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final data = await GFunDatePick.showCustomDatePicker(context,
                    firstDate: DateTime.now(),
                    initialDate:
                        startDate ?? DateTime.now().add(Duration(days: 1)),
                    lastDate: DateTime.now().add(Duration(days: 365)));
                if (data != null) {
                  onStartDatePicked(data);
                }
              },
              child: GWidgetTextField(
                enabled: false,
                labelText: 'Start Date'.tr,
                hintText: 'dd MMM yyy', //,'00:00 AM/PM',
                errorMsg: startDateErrorMsg,
                controller: startDate == null
                    ? null
                    : TextEditingController(
                        text: DateFormat('dd MMM yyy').format(startDate!)),
                suffixIcon: Icon(
                  Icons.date_range,
                  color: startDate == null
                      ? AppTheme.iconGrey
                      : AppTheme.primary,
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final data = await GFunDatePick.showCustomTimePicker(
                  context,
                );
                if (data != null) {
                  onStartTimeChanged(data);
                }
              },
              child: GWidgetTextField(
                enabled: false,
                labelText: 'Start Time'.tr,
                hintText: '00:00 AM/PM'.tr,
                errorMsg: startTimeErrorMsg,
                controller: startTime == null
                    ? null
                    : TextEditingController(
                        text: startTime?.format(context) ?? ''),
                suffixIcon: Icon(
                  Icons.watch_later_outlined,
                  color: startTime == null
                      ? AppTheme.iconGrey
                      : AppTheme.primary,
                ),
              ),
            ),
            SizedBox(height: 16),
            GWidgetTextField(
              controller: problem,
              labelText: 'Problem'.tr,
              hintText:
                  'e.g., AC unit in the master bedroom is blowing warm air. The outdoor compressor is making a loud buzzing noise....'.tr,
              maxLines: 5,
              maxLength: 1000,
            ),
            SizedBox(height: 16),
            GWidgetTextField(
              controller: notes,
              labelText: 'Notes'.tr,
              hintText:
                  'e.g., Gate code is 1234, call 10 mins before arrival...'.tr,
              maxLines: 4,
              maxLength: 250,
            ),
          ],
        ));
  }
}
