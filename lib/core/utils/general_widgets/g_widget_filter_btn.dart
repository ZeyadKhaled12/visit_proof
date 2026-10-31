import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

/// Square filter button with a badge showing how many filters are active.
class GWidgetFilterBtn extends StatelessWidget {
  const GWidgetFilterBtn(
      {super.key, required this.activeCount, required this.onTap});
  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.fabShadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.tune_rounded,
                color: AppTheme.onPrimary, size: 24),
          ),
          if (activeCount > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: AppTheme.statOrange, shape: BoxShape.circle),
                child: Text('$activeCount',
                    style: AppTheme.font(
                        color: AppTheme.onPrimary,
                        fontSize: AppTheme.textMicro,
                        fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      ),
    );
  }
}
