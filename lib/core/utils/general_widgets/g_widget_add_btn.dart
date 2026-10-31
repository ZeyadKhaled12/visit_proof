import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

class GWidgetAddBtn extends StatelessWidget {
  const GWidgetAddBtn({super.key, required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppTheme.secondary,
        splashColor: AppTheme.secondary.withValues(alpha: .4),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline,
                  color: AppTheme.primary, size: 20),
              SizedBox(width: 5),
              Text(text,
                  style: AppTheme.font(
                      fontSize: AppTheme.textSmall,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}
