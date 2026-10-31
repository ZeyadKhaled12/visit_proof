import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/enums/priority_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_models/g_model_site.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_bottom_sheet.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_drop_down.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_text_field.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_client_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/usecases/visit_detail_actions_uc.dart';

class VisitDetailEditSheet extends StatefulWidget {
  final VisitDetailModel visit;
  final List<VisitClientModel> clients;
  final List<ServiceModel> services;
  const VisitDetailEditSheet(
      {super.key,
      required this.visit,
      required this.clients,
      required this.services});
  @override
  State<VisitDetailEditSheet> createState() => _VisitDetailEditSheetState();
}

class _VisitDetailEditSheetState extends State<VisitDetailEditSheet> {
  VisitClientModel? client;
  GModelSite? site;
  ServiceModel? service;
  Priority? priority;
  DateTime? start;
  bool beforePhotos = false, afterPhotos = false, allowOverride = false;
  late final TextEditingController price;
  late final TextEditingController duration;
  late final TextEditingController notes;
  late final TextEditingController problem;
  late final TextEditingController checklist;
  late final TextEditingController reason;

  bool get draft => widget.visit.status == VisitStatus.draft;
  bool get scheduled => widget.visit.status == VisitStatus.scheduled;
  bool get assigned => widget.visit.status == VisitStatus.assigned;
  bool get onWay => widget.visit.status == VisitStatus.onWay;
  bool get working => widget.visit.status == VisitStatus.inProgress;
  bool get canCore => draft || scheduled;
  bool get canSchedule => draft || scheduled || assigned;
  bool get canChecklist => canSchedule;
  bool get canPrice => canSchedule || onWay || working;

  @override
  void initState() {
    super.initState();
    client = widget.visit.client;
    site = widget.visit.site;
    priority = widget.visit.priority;
    service = widget.services
        .where((s) => s.serviceName == widget.visit.serviceName)
        .firstOrNull;
    start = widget.visit.startDate;
    beforePhotos = widget.visit.requireBeforeWorkPhotos ?? false;
    afterPhotos = widget.visit.requireAfterWorkPhotos ?? false;
    price = TextEditingController(text: widget.visit.price?.toString() ?? '');
    duration = TextEditingController(
        text: widget.visit.durationInMin?.toString() ?? '');
    notes = TextEditingController(
        text: (onWay || working) ? '' : widget.visit.notes ?? '');
    problem =
        TextEditingController(text: widget.visit.problemDescription ?? '');
    checklist =
        TextEditingController(text: (widget.visit.checkList ?? []).join('\n'));
    reason = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [price, duration, notes, problem, checklist, reason]) {
      c.dispose();
    }
    super.dispose();
  }

  List<VisitClientModel> get availableClients {
    final result = [...widget.clients];
    if (client != null && !result.any((c) => c.id == client?.id))
      result.insert(0, client!);
    return result;
  }

  List<GModelSite> get availableSites {
    final result = [...?client?.sites];
    if (site != null &&
        !result.any((s) => s.toJson().toString() == site!.toJson().toString()))
      result.insert(0, site!);
    return result;
  }

  List<ServiceModel> get availableServices {
    return widget.services;
  }

  Future<void> pickDate() async {
    final day = await showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialDate: start ?? DateTime.now());
    if (day == null || !mounted) return;
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(start ?? DateTime.now()));
    if (time == null || !mounted) return;
    setState(() =>
        start = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  void save() {
    if ((widget.visit.status == VisitStatus.completed ||
        widget.visit.status == VisitStatus.cancel)) return;
    num? newPrice;
    if (canPrice && price.text.trim().isNotEmpty) {
      newPrice = num.tryParse(price.text.trim());
      if (newPrice == null || !newPrice.toDouble().isFinite || newPrice < 0)
        return;
    }
    int? newDuration;
    if (canSchedule && duration.text.trim().isNotEmpty) {
      newDuration = int.tryParse(duration.text.trim());
      if (newDuration == null || newDuration <= 0) return;
    }
    if ((onWay || working) &&
        newPrice != widget.visit.price &&
        (!allowOverride || reason.text.trim().length < 8)) return;
    final newNote = (onWay || working)
        ? ((widget.visit.notes ?? '').isEmpty
            ? notes.text.trim()
            : (notes.text.trim().isEmpty
                ? widget.visit.notes!
                : '${widget.visit.notes}\n${notes.text.trim()}'))
        : notes.text.trim();
    final List<String> tasks = checklist.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updated = widget.visit.copyWith(
      client: draft ? client : widget.visit.client,
      site: canCore ? site : widget.visit.site,
      serviceName: canCore
          ? (service?.serviceName ?? widget.visit.serviceName)
          : widget.visit.serviceName,
      category: canCore
          ? (service?.category ?? widget.visit.category)
          : widget.visit.category,
      price: canPrice ? newPrice : widget.visit.price,
      durationInMin: canSchedule ? newDuration : widget.visit.durationInMin,
      startDate: canSchedule ? start : widget.visit.startDate,
      priority: priority,
      notes: newNote,
      problemDescription:
          working ? widget.visit.problemDescription : problem.text.trim(),
      checkList: canChecklist ? tasks : widget.visit.checkList,
      requireBeforeWorkPhotos:
          canChecklist ? beforePhotos : widget.visit.requireBeforeWorkPhotos,
      requireAfterWorkPhotos:
          canChecklist ? afterPhotos : widget.visit.requireAfterWorkPhotos,
    );
    Navigator.pop(
        context,
        UpdateVisitParameters(
            original: widget.visit,
            updated: updated,
            allowPriceOverride: allowOverride,
            reason: reason.text.trim()));
  }

  Widget _gap() => const SizedBox(height: 12);

  @override
  Widget build(BuildContext context) => GWidgetBottomSheet(
        title: 'Edit visit',
        subtitle: 'Only editable fields for the current status are shown.',
        body: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              if (draft) ...[
                GWidgetDropDown<VisitClientModel>(
                    labelText: 'Client',
                    value: client,
                    enableSearch: true,
                    items: availableClients
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name ?? 'Client',
                                style: AppFonts(color: AppColors.textPrimary))))
                        .toList(),
                    onChanged: (v) => setState(() {
                          client = v;
                          site = null;
                        })),
                _gap(),
              ],
              if (canCore) ...[
                GWidgetDropDown<GModelSite>(
                    labelText: 'Site',
                    value: site,
                    items: availableSites
                        .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                                '${s.city?.name ?? ''} · ${s.addressDetail ?? ''}',
                                style: AppFonts(color: AppColors.textPrimary))))
                        .toList(),
                    onChanged: (v) => setState(() => site = v)),
                _gap(),
                GWidgetDropDown<ServiceModel>(
                    labelText: 'Service',
                    value: service,
                    enableSearch: true,
                    items: availableServices
                        .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.serviceName ?? 'Service',
                                style: AppFonts(color: AppColors.textPrimary))))
                        .toList(),
                    onChanged: (v) => setState(() {
                          service = v;
                          if (v?.defaultPrice != null)
                            price.text = v!.defaultPrice.toString();
                          if (v?.duration != null)
                            duration.text = v!.duration.toString();
                          if (v?.checkList != null)
                            checklist.text = v!.checkList!.join('\n');
                        })),
                _gap(),
              ],
              if (canSchedule) ...[
                GWidgetTextField(
                    controller: duration,
                    labelText: 'Duration (minutes)',
                    keyboardType: TextInputType.number),
                _gap(),
                OutlinedButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.event_outlined,
                        color: AppColors.primary),
                    label: Text(
                        start == null
                            ? 'Select date & time'
                            : start.toString().split('.').first,
                        style:
                            AppFonts(color: AppColors.primary, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary))),
                _gap(),
              ],
              if (canPrice) ...[
                GWidgetTextField(
                    controller: price,
                    labelText: 'Visit price',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true)),
                _gap(),
              ],
              GWidgetDropDown<Priority>(
                  labelText: 'Priority',
                  value: priority,
                  items: Priority.values
                      .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(PrioritySwitch(priorityEnum: p).getText(),
                              style: AppFonts(color: AppColors.textPrimary))))
                      .toList(),
                  onChanged: (v) => setState(() => priority = v)),
              _gap(),
              if (!working) ...[
                GWidgetTextField(
                    controller: problem,
                    labelText: 'Problem description',
                    maxLines: 3),
                _gap(),
              ],
              GWidgetTextField(
                  controller: notes,
                  labelText: onWay || working
                      ? 'Add instructions / notes (append only)'
                      : 'Notes',
                  maxLines: 3),
              if (canChecklist) ...[
                _gap(),
                GWidgetTextField(
                    controller: checklist,
                    labelText: 'Checklist (one item per line)',
                    maxLines: 4),
                SwitchListTile(
                    value: beforePhotos,
                    activeTrackColor: AppColors.secondary,
                    title: Text('Require before photos',
                        style: AppFonts(
                            color: AppColors.textPrimary, fontSize: 13)),
                    onChanged: (v) => setState(() => beforePhotos = v)),
                SwitchListTile(
                    value: afterPhotos,
                    activeTrackColor: AppColors.secondary,
                    title: Text('Require after photos',
                        style: AppFonts(
                            color: AppColors.textPrimary, fontSize: 13)),
                    onChanged: (v) => setState(() => afterPhotos = v)),
              ],
              if (onWay || working) ...[
                _gap(),
                CheckboxListTile(
                    activeColor: AppColors.primary,
                    value: allowOverride,
                    title: Text('Approved price override (if price changed)',
                        style: AppFonts(
                            color: AppColors.textPrimary, fontSize: 12)),
                    onChanged: (v) =>
                        setState(() => allowOverride = v ?? false)),
                GWidgetTextField(
                    controller: reason,
                    labelText: 'Reason (required for price change)'),
              ],
              const SizedBox(height: 22),
              GWidgetButton(
                  text: 'Save changes', fontSize: 14, onPressed: save),
            ])),
      );
}
