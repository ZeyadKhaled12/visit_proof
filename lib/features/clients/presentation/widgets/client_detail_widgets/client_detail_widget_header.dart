import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/core/utils/assets_manager.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_launch.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_location_view_scr.dart';

import '../../../../../configs/app_theme.dart';
import '../../../data/models/client_detail_model/client_detail_model.dart';

class ClientDetailWidgetHeader extends StatelessWidget {
  const ClientDetailWidgetHeader({super.key, required this.clientDetailModel});
  final ClientDetailModel clientDetailModel;

  @override
  Widget build(BuildContext context) {
    final bool hasCoordinates = clientDetailModel.site?.latitude != null &&
        clientDetailModel.site?.longitude != null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 90,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.iconLightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppTheme.primary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        clientDetailModel.name?.substring(0, 1).toUpperCase() ??
                            'C',
                        style: AppTheme.font(
                          color: AppTheme.primary,
                          fontSize: AppTheme.textDisplay,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientDetailModel.name ?? 'Unknown Client'.tr,
                          style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textTitleLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.locationChipBg,
                              borderRadius: BorderRadius.circular(8),
                              border: hasCoordinates
                                  ? Border.all(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.3))
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 14, color: AppTheme.statOrange),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        clientDetailModel.site?.addressDetail ??
                                            'No Address'.tr,
                                        style: AppTheme.font(
                                            color: AppTheme.textDarkHint,
                                            fontSize: AppTheme.textSmall,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (hasCoordinates)
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      GWidgetLocationViewScr(
                                                          latitude:
                                                              clientDetailModel
                                                                  .site!
                                                                  .latitude!,
                                                          longitude:
                                                              clientDetailModel
                                                                  .site!
                                                                  .longitude!),
                                                ));
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppTheme.primary
                                                      .withValues(alpha: 0.2)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.map_rounded,
                                                    size: 14,
                                                    color: AppTheme.primary),
                                                const SizedBox(width: 4),
                                                Text('Map'.tr,
                                                    style: AppTheme.font(
                                                        color:
                                                            AppTheme.primary,
                                                        fontSize: AppTheme.textCaption,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () async {
                                            await GFunLaunch
                                                .navigateToGoogleMaps(
                                                    latitude: clientDetailModel
                                                        .site!.latitude!,
                                                    longitude: clientDetailModel
                                                        .site!.longitude!);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.statGreen
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppTheme.statGreen
                                                      .withValues(alpha: 0.2)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.directions,
                                                    size: 14,
                                                    color: AppTheme.statGreen),
                                                const SizedBox(width: 4),
                                                Text('Directions'.tr,
                                                    style: AppTheme.font(
                                                        color:
                                                            AppTheme.statGreen,
                                                        fontSize: AppTheme.textCaption,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ContactRowWidget(
                      icon: Icons.phone,
                      text: clientDetailModel.phone ?? 'No Phone'.tr,
                      iconColor: clientDetailModel.isWhatsAppPhone == true
                          ? AppTheme.whatsappGreen
                          : AppTheme.primary,
                      showWhatsapp: clientDetailModel.isWhatsAppPhone == true,
                    ),
                  ),
                  SizedBox(width: 10),
                  GWidgetButton(
                    height: 34,
                    paddingLeftRight: 5,
                    raduis: 10,
                    backgroundColor: AppTheme.primary.withValues(alpha: .8),
                    paddingTopBottom: 0,
                    onPressed: ()async {
                        if (clientDetailModel.phone == null) return;
                      await GFunLaunch.makePhoneCall(clientDetailModel.phone!);
                    },
                    widget: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: AppTheme.cardColor,
                        ),
                        Icon(Icons.navigate_next_outlined,
                            color: AppTheme.cardColor, size: 14)
                      ],
                    ),
                  ),
                  if (clientDetailModel.isWhatsAppPhone ?? false) ...[
                    SizedBox(width: 5),
                    GWidgetButton(
                      height: 34,
                      paddingLeftRight: 5,
                      raduis: 10,
                      backgroundColor:
                          AppTheme.whatsappGreen.withValues(alpha: .8),
                      paddingTopBottom: 0,
                      onPressed: () async {
                        if (clientDetailModel.phone == null) return;
                        await GFunLaunch.openWhatsApp(clientDetailModel.phone!);
                      },
                      widget: Row(
                        children: [
                          Image.asset(
                            IconAsset.whatsapp,
                            width: 14,
                            height: 14,
                            color: AppTheme.cardColor,
                          ),
                          Icon(Icons.navigate_next_outlined,
                              color: AppTheme.cardColor, size: 14)
                        ],
                      ),
                    )
                  ]
                ],
              ),
              const SizedBox(height: 8),
              _ContactRowWidget(
                icon: Icons.email,
                text: clientDetailModel.email ?? 'No Email'.tr,
                iconColor: AppTheme.statOrange,
                showWhatsapp: false,
              ),
              const SizedBox(height: 16),
              Divider(color: AppTheme.locationChipBg, thickness: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItemWidget(
                      title: 'Total Orders'.tr,
                      value: clientDetailModel.ordersCount?.toString() ?? '0',
                      color: AppTheme.primary),
                  Container(
                      height: 30, width: 1, color: AppTheme.locationChipBg),
                  _StatItemWidget(
                      title: 'Total Paid'.tr,
                      value:
                          '${App.currency} ${clientDetailModel.totalPaid ?? 0}',
                      color: AppTheme.statGreen),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactRowWidget extends StatelessWidget {
  const _ContactRowWidget(
      {required this.icon,
      required this.text,
      required this.iconColor,
      required this.showWhatsapp});
  final IconData icon;
  final String text;
  final Color iconColor;
  final bool showWhatsapp;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  color: iconColor, fontSize: AppTheme.textBody, fontWeight: FontWeight.bold),
            ),
          ),
          if (showWhatsapp) ...[
            SizedBox(width: 5),
            Image.asset(IconAsset.whatsapp,
                color: AppTheme.whatsappGreen, width: 18, height: 18)
          ]
        ],
      ),
    );
  }
}

class _StatItemWidget extends StatelessWidget {
  const _StatItemWidget(
      {required this.title, required this.value, required this.color});
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style:
              AppTheme.font(color: color, fontSize: AppTheme.textHeadline, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: AppTheme.font(color: AppTheme.textSecondary, fontSize: AppTheme.textSmall),
        ),
      ],
    );
  }
}
