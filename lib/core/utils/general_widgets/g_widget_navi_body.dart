import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';
import 'g_widget_tour.dart';

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
                padding: EdgeInsetsDirectional.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 8,
                  start: 8,
                  end: 20,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(
                      bottom: BorderSide(color: AppTheme.iconLightGrey)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary, size: 22),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textTitleLarge,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const GWidgetTourFlagSpace(),
                  ],
                ),
              ),
              Expanded(child: body)
            ],
          ),
        ));
  }
}
