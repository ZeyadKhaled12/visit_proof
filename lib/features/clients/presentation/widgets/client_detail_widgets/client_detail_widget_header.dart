import 'package:flutter/material.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/core/utils/assets_manager.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_launch.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_location_view_scr.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
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
          decoration: const BoxDecoration(
            color: AppColors.primary,
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
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
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
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.secondary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        clientDetailModel.name?.substring(0, 1).toUpperCase() ??
                            'C',
                        style: AppFonts(
                          color: AppColors.secondary,
                          fontSize: 24,
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
                          clientDetailModel.name ?? 'Unknown Client',
                          style: AppFonts(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.locationChipBg,
                              borderRadius: BorderRadius.circular(8),
                              border: hasCoordinates
                                  ? Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3))
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 14, color: AppColors.statOrange),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        clientDetailModel.site?.addressDetail ??
                                            'No Address',
                                        style: AppFonts(
                                            color: AppColors.textDarkHint,
                                            fontSize: 12,
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
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.2)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.map_rounded,
                                                    size: 14,
                                                    color: AppColors.primary),
                                                const SizedBox(width: 4),
                                                Text('Map',
                                                    style: AppFonts(
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: 11,
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
                                              color: AppColors.statGreen
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppColors.statGreen
                                                      .withValues(alpha: 0.2)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.directions,
                                                    size: 14,
                                                    color: AppColors.statGreen),
                                                const SizedBox(width: 4),
                                                Text('Directions',
                                                    style: AppFonts(
                                                        color:
                                                            AppColors.statGreen,
                                                        fontSize: 11,
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
                      text: clientDetailModel.phone ?? 'No Phone',
                      iconColor: clientDetailModel.isWhatsAppPhone == true
                          ? AppColors.whatsappGreen
                          : AppColors.primary,
                      showWhatsapp: clientDetailModel.isWhatsAppPhone == true,
                    ),
                  ),
                  SizedBox(width: 10),
                  GWidgetButton(
                    height: 34,
                    paddingLeftRight: 5,
                    raduis: 10,
                    backgroundColor: AppColors.primary.withValues(alpha: .8),
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
                          color: AppColors.cardColor,
                        ),
                        Icon(Icons.navigate_next_outlined,
                            color: AppColors.cardColor, size: 14)
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
                          AppColors.whatsappGreen.withValues(alpha: .8),
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
                            color: AppColors.cardColor,
                          ),
                          Icon(Icons.navigate_next_outlined,
                              color: AppColors.cardColor, size: 14)
                        ],
                      ),
                    )
                  ]
                ],
              ),
              const SizedBox(height: 8),
              _ContactRowWidget(
                icon: Icons.email,
                text: clientDetailModel.email ?? 'No Email',
                iconColor: AppColors.statOrange,
                showWhatsapp: false,
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.locationChipBg, thickness: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItemWidget(
                      title: 'Total Orders',
                      value: clientDetailModel.ordersCount?.toString() ?? '0',
                      color: AppColors.primary),
                  Container(
                      height: 30, width: 1, color: AppColors.locationChipBg),
                  _StatItemWidget(
                      title: 'Total Paid',
                      value:
                          '${App.currency} ${clientDetailModel.totalPaid ?? 0}',
                      color: AppColors.statGreen),
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
              style: AppFonts(
                  color: iconColor, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          if (showWhatsapp) ...[
            SizedBox(width: 5),
            Image.asset(IconAsset.whatsapp,
                color: AppColors.whatsappGreen, width: 18, height: 18)
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
              AppFonts(color: color, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: AppFonts(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
