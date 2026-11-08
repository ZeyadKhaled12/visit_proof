import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/core/utils/assets_manager.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_launch.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import '../../../../../configs/app_theme.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../data/models/client_detail_model/client_detail_model.dart';
import '../../controller/clients_bloc.dart';
import '../../screens/client_detail_scr.dart';

class ClientsWidgetCard extends StatelessWidget {
  const ClientsWidgetCard({super.key, required this.client});
  final ClientDetailModel client;

  @override
  Widget build(BuildContext context) {
    // All cards now use the same unified theme color

    final String initial = (client.name != null && client.name!.isNotEmpty)
        ? client.name![0].toUpperCase()
        : "?";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (client.id != null) {
            final data = await Navigator.pushNamed(
                context, ClientDetailScr.route,
                arguments: ClientDetailArgu(clientID: client.id!).toArgu());
            if (data is bool) {
              if (data) {
                context
                    .read<ClientsBloc>()
                    .add(GetClientsEvent(noParameters: NoParameters()));
              }
            }
          }
        },
        highlightColor: AppTheme.primary.withValues(alpha: 0.05),
        splashColor: AppTheme.primary.withValues(alpha: 0.1),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: BorderDirectional(
                start: BorderSide(color: AppTheme.primary, width: 5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unified Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primary.withValues(alpha: .12),
                child: Text(
                  initial,
                  style: AppTheme.font(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.textTitleLarge,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Data Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Name & City
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            client.name ?? "Unknown".tr,
                            style: AppTheme.font(
                              fontSize: AppTheme.textTitle,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (client.site?.city != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.locationChipBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 12, color: AppTheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  (client.site?.city?.name ?? '').tr,
                                  style: AppTheme.font(
                                      fontSize: AppTheme.textCaption,
                                      color: AppTheme.textDarkHint,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Row 2: Contact Info (Wrap)
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (client.phone != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_rounded,
                                  size: 13,
                                  color: (client.isWhatsAppPhone ?? false)
                                      ? AppTheme.whatsappGreen
                                      : AppTheme.iconLightGrey),
                              const SizedBox(width: 4),
                              Text(client.phone!,
                                  style: AppTheme.font(
                                      fontSize: AppTheme.textSmall,
                                      color: AppTheme.textDarkHint)),
                              if (client.isWhatsAppPhone ?? false) ...[
                                const SizedBox(width: 4),
                                Image.asset(IconAsset.whatsapp,
                                    width: 14,
                                    height: 14,
                                    color: AppTheme.whatsappGreen)
                              ]
                            ],
                          ),
                        if (client.email != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.email_rounded,
                                  size: 13, color: AppTheme.iconGrey),
                              const SizedBox(width: 4),
                              Text(client.email!,
                                  style: AppTheme.font(
                                      fontSize: AppTheme.textSmall,
                                      color: AppTheme.textDarkHint)),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Row 3: Stats & Notes
                    Row(
                      children: [
                        // Orders Chip
                        _TinyStateWidget(
                          icon: Icons.shopping_cart_rounded,
                          text: "${client.ordersCount ?? 0}",
                          color: AppTheme.statOrange,
                        ),
                        const SizedBox(width: 8),
                        // Paid Chip
                        _TinyStateWidget(
                          text:
                              '${App.currency} ${client.totalPaid?.toStringAsFixed(2) ?? '0'}',
                          color: AppTheme.statGreen,
                        ),
                      ],
                    ),
                    if (client.phone != null) ...[
                      SizedBox(height: 8),
                      _ContactActionButtons(
                          phoneNumber: client.phone!,
                          hasWhatsapp: client.isWhatsAppPhone ?? false)
                    ]
                  ],
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                  color: AppTheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyStateWidget extends StatelessWidget {
  const _TinyStateWidget({this.icon, required this.text, required this.color});
  final IconData? icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTheme.font(
              fontSize: AppTheme.textCaption,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactActionButtons extends StatelessWidget {
  final String phoneNumber;
  final bool hasWhatsapp;

  const _ContactActionButtons({
    required this.phoneNumber,
    this.hasWhatsapp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GWidgetButton(
          height: 30,
          onPressed: () async {
            await GFunLaunch.makePhoneCall(phoneNumber);
          },
          backgroundColor: AppTheme.cardColor,
          paddingTopBottom: 0,
          border: Border.all(color: AppTheme.primary),
          widget: Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 18,
                color: AppTheme.primary,
              ),
              SizedBox(width: 10),
              Text(
                "Call".tr,
                style: AppTheme.font(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: AppTheme.textSmall,
                ),
              )
            ],
          ),
        ),
        if (hasWhatsapp) ...[
          const SizedBox(width: 6),
          GWidgetButton(
            height: 30,
            onPressed: () async {
              await GFunLaunch.openWhatsApp(phoneNumber);
            },
            backgroundColor: AppTheme.cardColor,
            paddingTopBottom: 0,
            border: Border.all(color: AppTheme.whatsappGreen),
            widget: Row(
              children: [
                Image.asset(
                  IconAsset.whatsapp,
                  width: 18,
                  height: 18,
                  color: AppTheme.whatsappGreen,
                ),
                SizedBox(width: 10),
                Text(
                  "WhatsApp".tr,
                  style: AppTheme.font(
                    color: AppTheme.whatsappGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: AppTheme.textSmall,
                  ),
                )
              ],
            ),
          )
        ],
      ],
    );
  }
}
