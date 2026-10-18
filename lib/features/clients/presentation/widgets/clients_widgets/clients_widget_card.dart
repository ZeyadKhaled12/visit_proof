import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/core/utils/assets_manager.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_launch.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../data/models/client_model.dart';
import '../../controller/clients_bloc.dart';
import '../../screens/client_detail_scr.dart';

class ClientsWidgetCard extends StatelessWidget {
  const ClientsWidgetCard({super.key, required this.client});
  final ClientModel client;

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
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: const Border(
                left: BorderSide(color: AppColors.primary, width: 5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadowColor.withValues(alpha: .03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unified Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: .12),
                child: Text(
                  initial,
                  style: AppFonts(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
                            client.name ?? "Unknown",
                            style: AppFonts(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (client.city != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.locationChipBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  client.city?.name ?? '',
                                  style: AppFonts(
                                      fontSize: 11,
                                      color: AppColors.textDarkHint,
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
                                      ? AppColors.whatsappGreen
                                      : AppColors.iconLightGrey),
                              const SizedBox(width: 4),
                              Text(client.phone!,
                                  style: AppFonts(
                                      fontSize: 12,
                                      color: AppColors.textDarkHint)),
                              if (client.isWhatsAppPhone ?? false) ...[
                                const SizedBox(width: 4),
                                Image.asset(IconAsset.whatsapp,
                                    width: 14,
                                    height: 14,
                                    color: AppColors.whatsappGreen)
                              ]
                            ],
                          ),
                        if (client.email != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.email_rounded,
                                  size: 13, color: AppColors.iconLightGrey),
                              const SizedBox(width: 4),
                              Text(client.email!,
                                  style: AppFonts(
                                      fontSize: 12,
                                      color: AppColors.textDarkHint)),
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
                          color: AppColors.statOrange,
                        ),
                        const SizedBox(width: 8),
                        // Paid Chip
                        _TinyStateWidget(
                          text:
                              '${App.currency} ${client.totalPaid?.toStringAsFixed(2) ?? '0'}',
                          color: AppColors.statGreen,
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
                  color: AppColors.primary.withValues(alpha: 0.5),
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
            style: AppFonts(
              fontSize: 11,
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
          backgroundColor: AppColors.cardColor,
          paddingTopBottom: 0,
          border: Border.all(color: AppColors.primary),
          widget: Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                "Call",
                style: AppFonts(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
            backgroundColor: AppColors.cardColor,
            paddingTopBottom: 0,
            border: Border.all(color: AppColors.whatsappGreen),
            widget: Row(
              children: [
                Image.asset(
                  IconAsset.whatsapp,
                  width: 18,
                  height: 18,
                  color: AppColors.whatsappGreen,
                ),
                SizedBox(width: 10),
                Text(
                  "WhatsApp",
                  style: AppFonts(
                    color: AppColors.whatsappGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
