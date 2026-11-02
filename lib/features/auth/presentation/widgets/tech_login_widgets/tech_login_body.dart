import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_valid.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../domain/usecases/login_technician_uc.dart';
import '../../controller/auth_bloc.dart';

class TechLoginBody extends StatefulWidget {
  const TechLoginBody({super.key, required this.loading});
  final bool loading;

  @override
  State<TechLoginBody> createState() => _TechLoginBodyState();
}

class _TechLoginBodyState extends State<TechLoginBody> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_form.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(LoginTechnicianEvent(
        loginTechnicianParameters: LoginTechnicianParameters(
            email: _email.text.trim(), password: _password.text)));
  }

  @override
  Widget build(BuildContext context) {
    return GWidgetNaviBody(
      title: 'Technician sign in'.tr,
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.engineering_rounded,
                    color: AppTheme.secondary, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text('Welcome back'.tr,
                textAlign: TextAlign.center,
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textTitleLarge,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Use the email and password your admin created for you.'.tr,
                textAlign: TextAlign.center,
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.textBody,
                    height: 1.4)),
            const SizedBox(height: 28),
            GWidgetTextField(
              controller: _email,
              labelText: 'Email Address'.tr,
              hintText: 'name@company.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icon(Icons.alternate_email, color: AppTheme.primary),
              validator: (value) => GFunValid.isValidEmail(value ?? '')
                  ? null
                  : 'Please enter a valid email address'.tr,
            ),
            const SizedBox(height: 16),
            GWidgetTextField(
              controller: _password,
              labelText: 'Password'.tr,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              prefixIcon: Icon(Icons.lock_outline_rounded,
                  color: AppTheme.primary),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                    _hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.iconGrey),
              ),
              validator: (value) => (value ?? '').isEmpty
                  ? 'Please enter your password'.tr
                  : null,
            ),
            const SizedBox(height: 28),
            GWidgetButton(
              text: 'Sign in'.tr,
              fontSize: AppTheme.textSubtitle,
              height: 54,
              raduis: 14,
              isLoading: widget.loading,
              loadingSize: 22,
              loadingStrokeWidth: 3,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            Text('Forgot your password? Ask your admin to set a new one.'.tr,
                textAlign: TextAlign.center,
                style: AppTheme.font(
                    color: AppTheme.textLightHint,
                    fontSize: AppTheme.textSmall)),
          ],
        ),
      ),
    );
  }
}
