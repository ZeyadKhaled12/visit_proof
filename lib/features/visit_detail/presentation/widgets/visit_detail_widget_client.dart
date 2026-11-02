import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/general_functions.dart/g_fun_launch.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../../../core/utils/general_widgets/g_widget_location_view_scr.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/visit_rules.dart';
import 'sheets/visit_detail_widget_site_sheet.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_action_sheet.dart';
import 'visit_detail_widget_parts.dart';

class VisitDetailWidgetClient extends StatelessWidget {
  const VisitDetailWidgetClient({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  Widget build(BuildContext context) {
    final client = visit.client;
    final phone = client?.phone ?? '';

    return VisitDetailSection(
      title: 'Client & Site'.tr,
      icon: Icons.person_pin_circle_rounded,
      color: AppTheme.secondary,
      actionText: 'Change site'.tr,
      actionIcon: Icons.edit_location_alt_rounded,
      onAction: VisitRules.canChangeSite(visit)
          ? () => VisitDetailWidgetActionSheet.show(
              context, VisitDetailWidgetSiteSheet(visit: visit))
          : null,
      child: client == null
          ? VisitDetailEmpty(
              icon: Icons.person_off_rounded, text: 'No client selected'.tr)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    VisitDetailAvatar(
                      letter: VisitDetailHelpers.initial(client.name),
                      colors: [AppTheme.secondary, AppTheme.primary],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.name ?? 'Unknown client'.tr,
                              style: AppTheme.font(
                                  color: AppTheme.textPrimary,
                                  fontSize: AppTheme.textTitle,
                                  fontWeight: FontWeight.w800)),
                          if ((client.email ?? '').isNotEmpty)
                            Text(client.email!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.font(
                                    color: AppTheme.textSecondary,
                                    fontSize: AppTheme.textSmall)),
                          if (phone.isNotEmpty)
                            Text(phone,
                                style: AppTheme.font(
                                    color: AppTheme.textDarkHint,
                                    fontSize: AppTheme.textSmall,
                                    fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      VisitDetailActionChip(
                        label: 'Call'.tr,
                        icon: Icons.phone_rounded,
                        color: AppTheme.primary,
                        onTap: () => GFunLaunch.makePhoneCall(phone),
                      ),
                      if (client.isWhatsAppPhone == true)
                        _WhatsAppChip(phone: phone),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                _SiteBox(site: visit.site),
              ],
            ),
    );
  }
}

class _WhatsAppChip extends StatelessWidget {
  const _WhatsAppChip({required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.whatsappGreen.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => GFunLaunch.openWhatsApp(phone),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(IconAsset.whatsapp,
                  width: 15, height: 15, color: AppTheme.whatsappGreen),
              const SizedBox(width: 5),
              Text('WhatsApp'.tr,
                  style: AppTheme.font(
                      color: AppTheme.whatsappGreen,
                      fontSize: AppTheme.textSmall,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SiteBox extends StatelessWidget {
  const _SiteBox({required this.site});
  final GModelSite? site;

  @override
  Widget build(BuildContext context) {
    final site = this.site;
    final hasCoordinates = site?.latitude != null && site?.longitude != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.locationChipBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_rounded,
                  color: AppTheme.statOrange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(site?.city?.name?.tr ?? 'No site selected'.tr,
                        style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textBodyLarge,
                            fontWeight: FontWeight.w800)),
                    if ((site?.addressDetail ?? '').isNotEmpty)
                      Text(site!.addressDetail!,
                          style: AppTheme.font(
                              color: AppTheme.textDarkHint,
                              fontSize: AppTheme.textSmall,
                              height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          if (site != null && hasCoordinates) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                VisitDetailActionChip(
                  label: 'Map'.tr,
                  icon: Icons.map_rounded,
                  color: AppTheme.primary,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GWidgetLocationViewScr(
                              latitude: site.latitude!,
                              longitude: site.longitude!))),
                ),
                VisitDetailActionChip(
                  label: 'Directions'.tr,
                  icon: Icons.directions_rounded,
                  color: AppTheme.statGreen,
                  onTap: () => VisitDetailHelpers.openDirections(site),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
