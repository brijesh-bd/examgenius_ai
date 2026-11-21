import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/brand_art.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_widgets.dart';

/// Login: brand header + illustration, headline, email/mobile + password,
/// remember me, gradient Login button, social options, sign-up link.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // Off until the first submit; then each field re-checks as the user types,
  // so an error disappears as soon as the field becomes valid.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;
  bool _obscure = true;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;
    // On success the router redirect sends the user to /home.
    await ref
        .read(authFormProvider.notifier)
        .login(_identifier.text.trim(), _password.text, rememberMe: _remember);
  }


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = ref.watch(authFormProvider);
    ref.listen(authFormProvider, (_, next) {
      if (next.hasError && !next.isLoading) showAuthError(context, next.error!);
    });
    final headColor = isDark ? AppColors.white : AppColors.headline;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.splashBgTop, AppColors.splashBgBottom],
                ),
          color: isDark ? scheme.surface : null,
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: BrandCornerWaves(soft: true)),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: CapBookLogo(width: 92)),
                        BrandWordmarkText(
                          size: AppFontSizes.display,
                          aiLabel: l10n.aiLabel,
                          semanticLabel: l10n.appName,
                        ),
                        Text(
                          l10n.appTagline,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.tagline(AppFontSizes.md,
                              isDark ? AppColors.white : AppColors.headline),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: StudyIllustration(),
                        ),
                        const SizedBox(height: 12),
                        Text.rich(
                          TextSpan(
                            style: AppTextStyles.h1.copyWith(
                                fontSize: AppFontSizes.h1 + 6, height: 1.15, color: headColor),
                            children: [
                              TextSpan(text: '${l10n.loginHeadlinePrepare} '),
                              TextSpan(
                                  text: l10n.loginHeadlineSmarter,
                                  style: const TextStyle(color: AppColors.brandBlue)),
                              TextSpan(text: '\n${l10n.loginHeadlineAchieve} '),
                              TextSpan(
                                  text: l10n.loginHeadlineMore,
                                  style: const TextStyle(color: AppColors.accent)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginTagline,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.tagline(AppFontSizes.lg,
                              isDark ? AppColors.white : AppColors.textMuted),
                        ),
                        const SizedBox(height: 18),
                        Form(
                          key: _formKey,
                          autovalidateMode: _autovalidate,
                          child: AutofillGroup(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _identifier,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.email,
                                    AutofillHints.telephoneNumber,
                                  ],
                                  style: AppTextStyles.bodyLarge,
                                  decoration:
                                      authFieldDecoration(context, l10n.emailOrMobile, Icons.mail_outline_rounded),
                                  validator: (v) =>
                                      Validators.emailOrMobile(v)?.message(l10n),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _submit(),
                                  style: AppTextStyles.bodyLarge,
                                  decoration: authFieldDecoration(context, 
                                    l10n.password,
                                    Icons.lock_outline_rounded,
                                    suffix: Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: IconButton(
                                        tooltip: l10n.password,
                                        icon: Icon(_obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined),
                                        onPressed: () => setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                  ),
                                  validator: (v) => Validators.password(v)?.message(l10n),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            SizedBox.square(
                              dimension: 40,
                              child: Checkbox(
                                value: _remember,
                                onChanged: (v) => setState(() => _remember = v ?? true),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _remember = !_remember),
                                child: Text(l10n.rememberMe, style: AppTextStyles.body),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push(AppRoutes.forgotPassword),
                              child: Text(l10n.forgotPassword,
                                  style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AuthGradientButton(
                          label: l10n.login,
                          loading: status.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider(indent: 24)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: Text(l10n.orUpper,
                                  style: AppTextStyles.body
                                      .copyWith(color: scheme.onSurfaceVariant)),
                            ),
                            const Expanded(child: Divider(endIndent: 24)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SocialButton(
                          icon: const Icon(Icons.smartphone_rounded,
                              color: AppColors.primary, size: 26),
                          label: l10n.continueWithMobileOtp,
                          onPressed: () => context.openComingSoon(l10n.continueWithMobileOtp),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(l10n.noAccount, style: AppTextStyles.body),
                            TextButton(
                              onPressed: () => context.push(AppRoutes.register),
                              child: Text(
                                l10n.signUp,
                                style: AppTextStyles.labelBold.copyWith(
                                  fontSize: AppFontSizes.xl,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label, required this.onPressed});

  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: scheme.surface,
        side: const BorderSide(color: AppColors.fieldBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 14),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.button.copyWith(
                    fontSize: AppFontSizes.lg + 1, color: scheme.onSurface)),
          ),
        ],
      ),
    );
  }
}
