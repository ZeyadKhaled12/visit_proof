import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_brand.dart';
import '../../../../configs/app_offer.dart';
import '../../../../configs/app_theme.dart';
import '../../../../core/utils/general_widgets/g_widget_brand_mark.dart';
import '../../data/datasource/website_request_remote_data_source.dart';
import '../../data/models/website_request_model.dart';
import '../widgets/studio_widget_panel.dart';
import '../widgets/website_widget_parts.dart';
import '../website_theme.dart';

/// The visitor sends the design they made, their contact details and any
/// notes. The request goes to the owner's database (not connected yet).
class WebsiteRequestScr extends StatefulWidget {
  const WebsiteRequestScr({super.key});

  @override
  State<WebsiteRequestScr> createState() => _WebsiteRequestScrState();
}

class _WebsiteRequestScrState extends State<WebsiteRequestScr> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _company = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _comments = TextEditingController();
  bool _custom = false;
  bool _agreed = false;
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _phone.dispose();
    _email.dispose();
    _comments.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_form.currentState?.validate() != true) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please confirm you have read the price.'.tr,
              style: WebTheme.font(color: WebTheme.onPrimary))));
      return;
    }
    setState(() => _sending = true);
    await WebsiteRequestRemoteDataSource().submitRequest(
      WebsiteRequestModel.fromStudio(
        name: _name.text,
        company: _company.text,
        phone: _phone.text,
        email: _email.text,
        customChanges: _custom,
        comments: _comments.text,
      ),
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Required'.tr : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: WebTheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: WebTheme.textPrimary),
        title: Text('Request your version'.tr,
            style: WebTheme.font(
                color: WebTheme.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        child: WebsiteSection(
          vertical: 28,
          child: _sent ? _sentView() : _formView(),
        ),
      ),
    );
  }

  Widget _sentView() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: WebsiteCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: WebTheme.statGreen.withValues(alpha: .14),
                child: Icon(Icons.check_rounded,
                    color: WebTheme.statGreen, size: 38),
              ),
              const SizedBox(height: 18),
              Text('Your request has been sent'.tr,
                  textAlign: TextAlign.center,
                  style: WebTheme.font(
                      color: WebTheme.textPrimary,
                      fontSize: WebTheme.textHeadline,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                  'We will contact you on {0} to confirm your request, then send you the private link to your app.'
                      .trArgs([_phone.text.trim()]),
                  textAlign: TextAlign.center,
                  style: WebTheme.font(
                      color: WebTheme.textSecondary,
                      fontSize: WebTheme.textBodyLarge,
                      height: 1.6)),
              const SizedBox(height: 24),
              WebsiteButton(
                text: 'Back to the website'.tr,
                icon: Icons.home_rounded,
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formView() {
    final wide = WebsiteLayout.isWide(context);

    final form = WebsiteCard(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label('Your details'.tr),
            _field(_name, 'Your name'.tr, validator: _required),
            _field(_company, 'Company name'.tr, validator: _required),
            _field(_phone, 'Phone / WhatsApp'.tr,
                keyboard: TextInputType.phone, validator: _required),
            _field(_email, 'Email (optional)'.tr,
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 6),
            _label('Which version do you want?'.tr),
            _VersionOption(
              selected: !_custom,
              title: 'Standard version with my design'.tr,
              subtitle:
                  'Everything in the demo with your colors, fonts, icon and name. Included in the plan.'
                      .tr,
              onTap: () => setState(() => _custom = false),
            ),
            const SizedBox(height: 10),
            _VersionOption(
              selected: _custom,
              title: 'I also need custom changes'.tr,
              subtitle:
                  'Their price depends on what you ask for. We discuss your request with you and agree on the price before any work starts.'
                      .tr,
              onTap: () => setState(() => _custom = true),
            ),
            const SizedBox(height: 18),
            _label(_custom
                ? 'Describe the changes you need'.tr
                : 'Notes (optional)'.tr),
            TextFormField(
              controller: _comments,
              maxLines: 5,
              maxLength: 1500,
              style: WebTheme.font(
                  color: WebTheme.textPrimary, fontSize: WebTheme.textBodyLarge),
              decoration: _decoration(_custom
                  ? 'e.g. add a field for the AC model, add my VAT number on the invoice…'
                      .tr
                  : 'Anything you want us to know'.tr),
              validator: (value) => _custom && (value ?? '').trim().length < 10
                  ? 'Tell us what to change (at least 10 characters).'.tr
                  : null,
            ),
          ],
        ),
      ),
    );

    final brand = AppBrand.value;
    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebsiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Your design'.tr),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GWidgetBrandMark(size: 30, color: AppTheme.onPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppBrand.appName,
                          style: WebTheme.font(
                              color: WebTheme.textPrimary,
                              fontSize: WebTheme.textTitle,
                              fontWeight: FontWeight.w800)),
                      Text(
                          [
                            AppTheme.isDark ? 'Dark'.tr : 'Light'.tr,
                            AppLanguage.isArabic ? 'العربية' : 'English',
                            AppTheme.activeFontFamily,
                            '${(brand.fontScale * 100).round()}%',
                          ].join(' · '),
                          style: WebTheme.font(
                              color: WebTheme.textSecondary,
                              fontSize: WebTheme.textSmall)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final slot in AppBrandColor.values)
                    Tooltip(
                      message:
                          '${slot.label} ${AppBrand.hex(StudioWidgetPanel.colorOf(slot))}',
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: StudioWidgetPanel.colorOf(slot),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color:
                                  WebTheme.iconLightGrey.withValues(alpha: .6)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon:
                    Icon(Icons.edit_rounded, color: WebTheme.primary, size: 18),
                label: Text('Change the design'.tr,
                    style: WebTheme.font(
                        color: WebTheme.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        WebsiteCard(
          borderColor: WebTheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('What you will pay'.tr),
              _PriceLine(
                  'Months 1 to {0}'.trArgs([AppOffer.freeMonths]), 'Free'.tr),
              _PriceLine(
                  'Every {0} months after that'.trArgs([AppOffer.periodMonths]),
                  AppOffer.usd(AppOffer.pricePerPeriod)),
              if (_custom)
                _PriceLine('Special requests'.tr, 'Priced per request'.tr),
              const SizedBox(height: 8),
              Text(AppOffer.summary,
                  style: WebTheme.font(
                      color: WebTheme.textSecondary,
                      fontSize: WebTheme.textSmall,
                      height: 1.5)),
              const SizedBox(height: 6),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: WebTheme.primary,
                value: _agreed,
                onChanged: (value) => setState(() => _agreed = value ?? false),
                title: Text('I have read the price and the terms.'.tr,
                    style: WebTheme.font(
                        color: WebTheme.textPrimary,
                        fontSize: WebTheme.textBodyLarge,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        WebsiteButton(
          text: _sending ? 'Sending…'.tr : 'Send my request'.tr,
          icon: Icons.send_rounded,
          expand: true,
          onPressed: _sending ? null : _send,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
            'Send us your design. We will contact you to confirm, then prepare your app and send you its private link.'
                .tr,
            style: WebTheme.font(
                color: WebTheme.textSecondary,
                fontSize: WebTheme.textTitle,
                height: 1.5)),
        const SizedBox(height: 20),
        wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: form),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: summary),
                ],
              )
            : Column(children: [form, const SizedBox(height: 16), summary]),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: WebTheme.font(
                color: WebTheme.textPrimary,
                fontSize: WebTheme.textSubtitle,
                fontWeight: FontWeight.w800)),
      );

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: WebTheme.font(
            color: WebTheme.textLightHint, fontSize: WebTheme.textBody),
        filled: true,
        fillColor: WebTheme.searchFieldBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: WebTheme.iconLightGrey.withValues(alpha: .5))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: WebTheme.iconLightGrey.withValues(alpha: .5))),
      );

  Widget _field(TextEditingController controller, String hint,
          {TextInputType? keyboard, String? Function(String?)? validator}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboard,
          validator: validator,
          style: WebTheme.font(
              color: WebTheme.textPrimary, fontSize: WebTheme.textBodyLarge),
          decoration: _decoration(hint),
        ),
      );
}

class _VersionOption extends StatelessWidget {
  const _VersionOption({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? WebTheme.primary.withValues(alpha: .07)
              : WebTheme.locationChipBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? WebTheme.primary : Colors.transparent,
              width: 1.6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? WebTheme.primary : WebTheme.iconGrey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: WebTheme.font(
                          color: WebTheme.textPrimary,
                          fontSize: WebTheme.textBodyLarge,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: WebTheme.font(
                          color: WebTheme.textSecondary,
                          fontSize: WebTheme.textSmall,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style: WebTheme.font(
                  color: WebTheme.textSecondary,
                  fontSize: WebTheme.textBodyLarge)),
        ),
        Text(value,
            style: WebTheme.font(
                color: WebTheme.textPrimary,
                fontSize: WebTheme.textBodyLarge,
                fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
