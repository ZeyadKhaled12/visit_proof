import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

class GWidgetNaviBody extends StatelessWidget {
  const GWidgetNaviBody({super.key, required this.title, required this.body});
  final String title;
  final Widget body;

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 24,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.scaffoldBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            color: AppTheme.textPrimary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textHeadline,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: body)
            ],
          ),
        ));
  }
}
