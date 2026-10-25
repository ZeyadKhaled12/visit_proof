import 'package:flutter/material.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/enums/technician_status_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_date_pick.dart';
import '../../../../core/utils/general_models/g_model_catg.dart';
import '../../../../core/utils/general_widgets/g_widget_add_btn.dart';
import '../../../../core/utils/general_widgets/g_widget_card_title.dart';
import '../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../technicians/data/models/technician_model.dart';
import 'package:intl/intl.dart';

final List<TechnicianModel> dummyTechnicians = [
  TechnicianModel(
    id: 'tech_001',
    name: 'Ahmed Hassan',
    phone: '+20 100 111 2222',
    openJobs: 0,
    status: TechnicianStatus.available,
    categories: [
      const GModelCatg(
          id: 'cat_hvac', name: 'HVAC', description: 'AC & Heating'),
      const GModelCatg(
          id: 'cat_elec', name: 'Electrical', description: 'Wiring & Panels'),
    ],
  ),
  TechnicianModel(
    id: 'tech_002',
    name: 'Zeyad Khaled',
    phone: '+20 111 333 4444',
    openJobs: 3,
    status: TechnicianStatus.busy,
    categories: [
      const GModelCatg(
          id: 'cat_hvac', name: 'HVAC', description: 'AC & Heating'),
    ],
  ),
  TechnicianModel(
    id: 'tech_003',
    name: 'Omar Youssef',
    phone: '+20 122 555 6666',
    openJobs: 1,
    status: TechnicianStatus.available,
    categories: [
      const GModelCatg(
          id: 'cat_plumb', name: 'Plumbing', description: 'Pipes & Water'),
    ],
  ),
  TechnicianModel(
    id: 'tech_004',
    name: 'Mahmoud Ali',
    phone: '+20 155 777 8888',
    openJobs: 0,
    status: TechnicianStatus.offline,
    categories: [
      const GModelCatg(
          id: 'cat_clean', name: 'Cleaning', description: 'Deep Cleaning'),
    ],
  ),
  TechnicianModel(
    id: 'tech_005',
    name: 'Tarek Ibrahim',
    phone: '+20 100 999 0000',
    openJobs: 5, // Heavy workload
    status: TechnicianStatus.busy,
    categories: [
      const GModelCatg(
          id: 'cat_elec', name: 'Electrical', description: 'Wiring & Panels'),
      const GModelCatg(
          id: 'cat_plumb', name: 'Plumbing', description: 'Pipes & Water'),
    ],
  ),
  TechnicianModel(
    id: 'tech_006',
    name: 'Karim Mostafa',
    phone: '+20 111 222 3333',
    openJobs: null, // Testing null safety
    status: null, // Testing null status handling
    categories: [], // Testing empty categories
  ),
];

class AddVisitWidgetSchedule extends StatelessWidget {
  const AddVisitWidgetSchedule(
      {super.key,
      this.selectedPriority,
      this.selectedTechnician,
      this.startDate,
      this.startTime,
      required this.onTechnicianChanged,
      required this.onPriorityChanged,
      required this.onStartDatePicked,
      required this.onStartTimeChanged});
  final Priority? selectedPriority;
  final TechnicianModel? selectedTechnician;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final Function(TechnicianModel? technician) onTechnicianChanged;
  final Function(Priority? priority) onPriorityChanged;
  final Function(DateTime startDate) onStartDatePicked;
  final Function(TimeOfDay startTime) onStartTimeChanged;

  @override
  Widget build(BuildContext context) {
    return GWidgetCardTitle(
        icon: Icons.assignment,
        title: 'Scheduling & Assignment',
        child: Column(
          children: [
            GWidgetDropDown<TechnicianModel>(
              labelText: 'Technician',
              searchHintText: 'Search for an technician',
              enableSearch: true,
              value: selectedTechnician,
              onChanged: onTechnicianChanged,
              items: dummyTechnicians.map((technician) {
                return DropdownMenuItem(
                  value: technician,
                  child: Text(technician.name ?? '',
                      style: AppFonts(fontWeight: FontWeight.w500)),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            GWidgetAddBtn(text: 'Add New Technician', onTap: () {}),
            SizedBox(height: 16),
            GWidgetDropDown<Priority>(
              labelText: 'Priority',
              value: selectedPriority,
              onChanged: onPriorityChanged,
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(PrioritySwitch(priorityEnum: priority).getText(),
                      style: AppFonts(fontWeight: FontWeight.w500)),
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
                labelText: 'Start Date',
                hintText: 'dd MMM yyy', //,'00:00 AM/PM',
                controller: startDate == null
                    ? null
                    : TextEditingController(
                        text: DateFormat('dd MMM yyy').format(startDate!)),
                suffixIcon: Icon(Icons.date_range),
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
                labelText: 'Start Time',
                hintText: '00:00 AM/PM',
                controller: startTime == null
                    ? null
                    : TextEditingController(
                        text: startTime?.format(context) ?? ''),
                suffixIcon: Icon(Icons.watch_later_outlined),
              ),
            ),
            SizedBox(height: 16),
            GWidgetTextField(
              labelText: 'Problem',
              hintText:
                  'AC unit in the master bedroom is blowing warm air. The outdoor compressor is making a loud buzzing noise....',
              maxLines: 5,
              maxLength: 1000,
            ),
            SizedBox(height: 16),
            GWidgetTextField(
              labelText: 'Notes',
              hintText:
                  'e.g., Gate code is 1234, call 10 mins before arrival...',
              maxLines: 4,
              maxLength: 250,
            ),
          ],
        ));
  }
}
