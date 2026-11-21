import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_widgets.dart';

/// Forgot password: email/mobile → "Send Reset Link" → confirmation with
/// resend. Same visual language as the login screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(forgotPasswordProvider.notifier)
        .send(_identifier.text.trim());
  }

  void _backToLogin() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);
    ref.listen(forgotPasswordProvider, (_, next) {
      if (next.hasError && !next.isLoading) showAuthError(context, next.error!);
    });
    final sentTo = state.value;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: _backToLogin,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: sentTo == null
                            ? _form(context, state.isLoading)
                            : _sent(context, sentTo, state.isLoading),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context, bool loading) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HeroIcon(
          icon: Icons.lock_reset_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            l10n.forgotTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(fontSize: AppFontSizes.h1 + 2),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.forgotSubtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.tagline(
            AppFontSizes.body,
            scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: TextFormField(
            controller: _identifier,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            autofillHints: const [
              AutofillHints.email,
              AutofillHints.telephoneNumber,
            ],
            onFieldSubmitted: (_) => _send(),
            style: AppTextStyles.bodyLarge,
            decoration: authFieldDecoration(
              context,
              l10n.emailOrMobile,
              Icons.mail_outline_rounded,
            ),
            validator: (v) => Validators.emailOrMobile(v)?.message(l10n),
          ),
        ),
        const SizedBox(height: 22),
        AuthGradientButton(
          label: l10n.sendResetLink,
          icon: Icons.send_rounded,
          loading: loading,
          onPressed: _send,
        ),
        const SizedBox(height: 18),
        _SecureNote(text: l10n.resetSecureNote),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.rememberPassword, style: AppTextStyles.body),
            TextButton(
              onPressed: _backToLogin,
              child: Text(
                l10n.login,
                style: AppTextStyles.labelBold.copyWith(
                  fontSize: AppFontSizes.lg,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sent(BuildContext context, String target, bool loading) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('sent'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HeroIcon(
          icon: Icons.mark_email_read_rounded,
          color: AppColors.success,
        ),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            l10n.resetSentTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(fontSize: AppFontSizes.h1 + 2),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.resetSentBody(target),
          textAlign: TextAlign.center,
          style: AppTextStyles.tagline(
            AppFontSizes.body,
            scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        AuthGradientButton(
          label: l10n.backToLogin,
          icon: Icons.login_rounded,
          onPressed: _backToLogin,
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.didntReceive, style: AppTextStyles.body),
            TextButton(
              onPressed: loading
                  ? null
                  : () =>
                        ref.read(forgotPasswordProvider.notifier).send(target),
              child: loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.resend,
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: AppFontSizes.lg,
                        color: AppColors.accent,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Large tinted circle with a centred icon and a soft glow.
class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.10),
        ),
        child: Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, Color.lerp(color, AppColors.accent, 0.5)!],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.white, size: 42),
          ),
        ),
      ),
    );
  }
}

class _SecureNote extends StatelessWidget {
  const _SecureNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
