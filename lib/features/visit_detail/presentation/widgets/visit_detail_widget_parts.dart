import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';

/// White card with a colored icon bubble, a title and an optional action.
class VisitDetailSection extends StatelessWidget {
  const VisitDetailSection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.actionText,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final String? actionText;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: .14)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 4, color: color),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            color.withValues(alpha: .22),
                            color.withValues(alpha: .08),
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(title,
                            style: AppTheme.font(
                                color: AppTheme.textPrimary,
                                fontSize: AppTheme.textTitle,
                                fontWeight: FontWeight.w800)),
                      ),
                      if (onAction != null && actionText != null)
                        VisitDetailActionChip(
                          label: actionText!,
                          icon: actionIcon ?? Icons.edit_rounded,
                          color: color,
                          onTap: onAction!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded label, tinted with [color].
class VisitDetailPill extends StatelessWidget {
  const VisitDetailPill({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.onDark = false,
  });

  final String text;
  final Color color;
  final IconData? icon;

  /// Solid white pill for use on gradient backgrounds.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: onDark ? AppTheme.surface : color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: AppTheme.font(
                  color: color, fontSize: AppTheme.textCaption, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// Small tinted button used for secondary actions inside cards.
class VisitDetailActionChip extends StatelessWidget {
  const VisitDetailActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: .2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(label,
                  style: AppTheme.font(
                      color: color, fontSize: AppTheme.textSmall, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colored tile with an icon, a big value and a caption.
class VisitDetailStatTile extends StatelessWidget {
  const VisitDetailStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textBodyLarge,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTheme.font(
                  color: color, fontSize: AppTheme.textCaption, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Label on the left, value on the right.
class VisitDetailInfoLine extends StatelessWidget {
  const VisitDetailInfoLine({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppTheme.font(color: AppTheme.textSecondary, fontSize: AppTheme.textBody)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: AppTheme.font(
                    color: valueColor ?? AppTheme.textPrimary,
                    fontSize: emphasize ? AppTheme.textTitle : AppTheme.textBody,
                    fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Soft box for long text such as the problem description or notes.
class VisitDetailTextBlock extends StatelessWidget {
  const VisitDetailTextBlock({
    super.key,
    required this.title,
    required this.text,
    required this.color,
  });

  final String title;
  final String? text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hasText = (text ?? '').trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTheme.font(
                  color: color, fontSize: AppTheme.textSmall, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(hasText ? text!.trim() : 'Nothing added yet'.tr,
              style: AppTheme.font(
                  color: hasText ? AppTheme.textDarkHint : AppTheme.textNotes,
                  fontSize: AppTheme.textBody,
                  height: 1.45)),
        ],
      ),
    );
  }
}

/// Inline message box for hints, warnings and blocked actions.
class VisitDetailNotice extends StatelessWidget {
  const VisitDetailNotice({
    super.key,
    required this.text,
    required this.color,
    this.icon = Icons.info_outline_rounded,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textSmall,
                    fontWeight: FontWeight.w600,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}

/// Circle with the first letter of a name on a gradient.
class VisitDetailAvatar extends StatelessWidget {
  const VisitDetailAvatar({
    super.key,
    required this.letter,
    required this.colors,
    this.size = 46,
  });

  final String letter;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Text(letter,
          style: AppTheme.font(
              color: AppTheme.onPrimary,
              fontSize: size * .42,
              fontWeight: FontWeight.w800)),
    );
  }
}

/// Placeholder shown when a section has nothing to display.
class VisitDetailEmpty extends StatelessWidget {
  const VisitDetailEmpty({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.locationChipBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.iconLightGrey, size: 28),
          const SizedBox(height: 6),
          Text(text,
              textAlign: TextAlign.center,
              style: AppTheme.font(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.textBody,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
