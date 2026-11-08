import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';

import 'g_widget_tour.dart';


class GWidgetBottomSheet extends StatelessWidget {
  const GWidgetBottomSheet(
      {super.key,
      required this.title,
      required this.help,
      this.subtitle,
      required this.body});
  final String title;

  /// What the help flag says about this sheet.
  final String help;
  final String? subtitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(bottom: bottomInset),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.iconLightGrey,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.font(
                        fontSize: AppTheme.textHeadline,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  GWidgetHelpButton(title: title, help: help),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppTheme.iconGrey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTheme.font(
                    fontSize: AppTheme.textBodyLarge,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textNotes,
                  ),
                ),
              SizedBox(height: 15),
              body
            ],
          ),
        ),
      ),
    );
  }
}
