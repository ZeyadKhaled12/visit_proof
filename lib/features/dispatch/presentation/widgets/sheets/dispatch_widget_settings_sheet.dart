import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_date_pick.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_choice_chip.dart';
import '../../../../../core/utils/general_widgets/g_widget_switcher.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../data/models/dispatch_settings_model.dart';
import '../../../domain/usecases/save_dispatch_settings_uc.dart';
import '../../controller/dispatch_bloc.dart';
import '../dispatch_widget_action_sheet.dart';

/// Company dispatch rules, editable without changing code.
class DispatchWidgetSettingsSheet extends StatefulWidget {
  const DispatchWidgetSettingsSheet({super.key});

  @override
  State<DispatchWidgetSettingsSheet> createState() =>
      _DispatchWidgetSettingsSheetState();
}

class _DispatchWidgetSettingsSheetState
    extends State<DispatchWidgetSettingsSheet> {
  static const List<int> _bufferOptions = [0, 15, 30, 45, 60];

  late DispatchSettingsModel _settings =
      context.read<DispatchBloc>().state.settings;

  String _clock(int minutes) =>
      VisitDetailHelpers.time(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));

  Future<void> _pickTime(int current, ValueChanged<int> onPicked) async {
    final picked = await GFunDatePick.showCustomTimePicker(context,
        initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60));
    if (picked != null) onPicked(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      title: 'Dispatch rules',
      subtitle: 'Applied to every assignment on the board',
      requestState: (state) => state.saveSettingsRequestState,
      builder: (context, state, loading) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Title('Working hours'),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(
                      _settings.workStart,
                      (value) => setState(() => _settings =
                          _settings.copyWith(workStartMinutes: value))),
                  child: VisitDetailStatTile(
                      icon: Icons.wb_sunny_rounded,
                      label: 'Day starts',
                      value: _clock(_settings.workStart),
                      color: AppTheme.pending),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(
                      _settings.workEnd,
                      (value) => setState(() =>
                          _settings = _settings.copyWith(workEndMinutes: value))),
                  child: VisitDetailStatTile(
                      icon: Icons.nights_stay_rounded,
                      label: 'Day ends',
                      value: _clock(_settings.workEnd),
                      color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Title('Visits per technician per day'),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: _settings.maxVisits > 1
                    ? () => setState(() => _settings = _settings.copyWith(
                        maxDailyVisits: _settings.maxVisits - 1))
                    : null,
              ),
              Expanded(
                child: Text('${_settings.maxVisits}',
                    textAlign: TextAlign.center,
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textDisplay,
                        fontWeight: FontWeight.w800)),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: _settings.maxVisits < 30
                    ? () => setState(() => _settings = _settings.copyWith(
                        maxDailyVisits: _settings.maxVisits + 1))
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Title('Travel time between visits'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final minutes in _bufferOptions)
                GWidgetChoiceChip(
                  label: minutes == 0 ? 'None' : '$minutes min',
                  color: AppTheme.secondary,
                  selected: _settings.travelBuffer == minutes,
                  onTap: () => setState(() => _settings =
                      _settings.copyWith(travelBufferMinutes: minutes)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          GWidgetSwitcher(
            title: 'Require matching specialty',
            subtitle: 'Off: a mismatch is only a warning',
            value: _settings.strictSkills,
            onChanged: (value) => setState(
                () => _settings = _settings.copyWith(strictSkillMatch: value)),
          ),
          const SizedBox(height: 18),
          VisitDetailNotice(
            text: 'Always enforced: no double booking, no visits on a day '
                'off, and visits must be complete before they are planned.',
            color: AppTheme.primary,
            icon: Icons.shield_rounded,
          ),
          const SizedBox(height: 16),
          GWidgetButton(
            text: 'Save rules',
            fontSize: AppTheme.textSubtitle,
            raduis: 14,
            isLoading: loading,
            loadingSize: 22,
            loadingStrokeWidth: 3,
            gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary]),
            onPressed: () => context.read<DispatchBloc>().add(
                SaveDispatchSettingsEvent(
                    saveDispatchSettingsParameters:
                        SaveDispatchSettingsParameters(settings: _settings))),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: AppTheme.font(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.textBodyLarge,
              fontWeight: FontWeight.w800)),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? AppTheme.primary.withValues(alpha: .12)
          : AppTheme.locationChipBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon,
              color: enabled ? AppTheme.primary : AppTheme.iconLightGrey),
        ),
      ),
    );
  }
}
