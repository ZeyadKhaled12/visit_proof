import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../website_theme.dart';
import 'website_widget_brand.dart';

/// Shared pieces of the sales website.
class WebsiteLayout {
  WebsiteLayout._();

  static const double maxWidth = 1120;

  /// Two or more columns from this width.
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 900;

  static double gutter(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600 ? 32 : 16;
}

/// A full-width band with centered, width-limited content.
class WebsiteSection extends StatelessWidget {
  const WebsiteSection({
    super.key,
    required this.child,
    this.color,
    this.vertical = 64,
    this.sectionKey,
  });

  final Widget child;
  final Color? color;
  final double vertical;
  final Key? sectionKey;

  @override
  Widget build(BuildContext context) {
    final gutter = WebsiteLayout.gutter(context);
    return Container(
      key: sectionKey,
      width: double.infinity,
      color: color,
      padding: EdgeInsets.symmetric(horizontal: gutter, vertical: vertical),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: WebsiteLayout.maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Small label, title and description above a section's content.
class WebsiteHeading extends StatelessWidget {
  const WebsiteHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.center = true,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final align = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(),
            textAlign: align,
            style: WebTheme.font(
                color: WebTheme.secondary,
                fontSize: WebTheme.textSmall,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        Text(title,
            textAlign: align,
            style: WebTheme.font(
                color: WebTheme.textPrimary,
                fontSize: WebsiteLayout.isWide(context) ? 32 : 24,
                fontWeight: FontWeight.w800,
                height: 1.25)),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(subtitle!,
                textAlign: align,
                style: WebTheme.font(
                    color: WebTheme.textSecondary,
                    fontSize: WebTheme.textTitle,
                    height: 1.6)),
          ),
        ],
      ],
    );
  }
}

/// Solid (primary) or outlined call-to-action button.
class WebsiteButton extends StatelessWidget {
  const WebsiteButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.color,
    this.foreground = WebTheme.onPrimary,
    this.expand = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final Color? color;

  /// Text and icon color of a solid button.
  final Color foreground;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? WebTheme.primary;
    final label = Text(text,
        style: WebTheme.font(
            color: outlined ? color : foreground,
            fontSize: WebTheme.textSubtitle,
            fontWeight: FontWeight.w800));
    final padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 18);
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    final Widget button = outlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon ?? Icons.arrow_forward_rounded,
                color: color, size: 20),
            label: label,
            style: OutlinedButton.styleFrom(
                padding: padding,
                shape: shape,
                side: BorderSide(color: color, width: 1.4)),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon ?? Icons.arrow_forward_rounded,
                color: foreground, size: 20),
            label: label,
            style: FilledButton.styleFrom(
                backgroundColor: color, padding: padding, shape: shape),
          );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// A white rounded card.
class WebsiteCard extends StatelessWidget {
  const WebsiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: WebTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: borderColor ?? WebTheme.iconLightGrey.withValues(alpha: .35),
            width: borderColor == null ? 1 : 1.6),
        boxShadow: [
          BoxShadow(
              color: WebTheme.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

/// Lays out cards in as many columns as fit, each at least [minWidth].
class WebsiteGrid extends StatelessWidget {
  const WebsiteGrid({
    super.key,
    required this.children,
    this.minWidth = 300,
    this.spacing = 18,
  });

  final List<Widget> children;
  final double minWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns =
          (constraints.maxWidth / minWidth).floor().clamp(1, children.length);
      final width =
          (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    });
  }
}

/// The website's own logo and name (Wizpo). It stays the same whatever the
/// visitor designs for their app.
class WebsiteLogo extends StatelessWidget {
  const WebsiteLogo({super.key, this.color = WebTheme.textPrimary});

  /// The wordmark's color: ink on light backgrounds, parchment on dark.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: WebsiteBrand.name,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const WizpoMark(size: 34),
          const SizedBox(width: 10),
          Text('wizpo',
              textDirection: TextDirection.ltr,
              style: WebsiteBrand.wordmark(fontSize: 26, color: color)),
        ],
      ),
    );
  }
}

/// A small rounded label, e.g. "Available now" or "Coming soon".
class WebsiteBadge extends StatelessWidget {
  const WebsiteBadge(
      {super.key, required this.text, required this.color, this.background});
  final String text;
  final Color color;

  /// Defaults to a soft tint of [color].
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text,
          style: WebTheme.font(
              color: color,
              fontSize: WebTheme.textSmall,
              fontWeight: FontWeight.w800,
              letterSpacing: .4)),
    );
  }
}

/// Language switch: shows the other language's name.
class WebsiteLanguageButton extends StatelessWidget {
  const WebsiteLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => AppLanguage.arabic.value = !AppLanguage.isArabic,
      icon: Icon(Icons.translate_rounded, color: WebTheme.textSecondary, size: 18),
      label: Text(AppLanguage.isArabic ? 'English' : 'العربية',
          style: WebTheme.font(
              color: WebTheme.textSecondary, fontWeight: FontWeight.w700)),
    );
  }
}

/// A row with a check icon, for "what you get" lists.
class WebsiteCheckLine extends StatelessWidget {
  const WebsiteCheckLine(
      {super.key, required this.text, this.icon, this.color});
  final String text;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? WebTheme.statGreen;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.check_circle_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: WebTheme.font(
                    color: WebTheme.textPrimary,
                    fontSize: WebTheme.textBodyLarge,
                    height: 1.5)),
          ),
        ],
      ),
    );
  }
}
