import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/brand_art.dart';
import '../../domain/student_user.dart';

/// Shared scaffold for login/register: logo, title, subtitle, scrollable form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glow = theme.brightness == Brightness.dark
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.authHeaderLight;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: showBack ? AppBar() : null,
      body: Stack(
        children: [
          // Soft brand glow in the top-left corner, as in the mockup.
          Positioned(
            top: -120,
            left: -120,
            child: IgnorePointer(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [glow, glow.withValues(alpha: 0)]),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ResponsiveCenter(
                maxWidth: 480,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!showBack) const SizedBox(height: 24),
                    const BrandWordmark(
                      logoSize: 64,
                      fontSize: AppFontSizes.h1,
                      taglineSize: 11,
                      decoratedTagline: true,
                    ),
                    const SizedBox(height: 36),
                    Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: AppFontSizes.h2)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// +91 prefixed, digits-only, 10-length mobile field.
class MobileField extends StatelessWidget {
  const MobileField({super.key, required this.controller, required this.validator});

  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: context.l10n.mobileNumber,
        prefixIcon: const Icon(Icons.smartphone_rounded, size: 20),
        prefixText: '+91  ',
      ),
      validator: validator,
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: widget.validator,
    );
  }
}

/// Maps an auth error to a localized snackbar.
void showAuthError(BuildContext context, Object error) {
  final l10n = context.l10n;
  final msg = error is AuthFailure && error.kind == AuthFailureKind.invalidCredentials
      ? l10n.errorInvalidCredentials
      : l10n.errorGeneric;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}

/// Pill-shaped blue gradient button with a login icon and a loading state.
class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon = Icons.login_rounded,
  });

  final String label;
  final bool loading;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30);
    return Semantics(
      button: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.loginButton,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: loading ? null : onPressed,
            child: SizedBox(
              height: 56,
              child: Center(
                child: loading
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: AppColors.white),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: AppColors.white, size: 26),
                          const SizedBox(width: 12),
                          ExcludeSemantics(
                            child: Text(label,
                                style: AppTextStyles.button.copyWith(
                                    fontSize: AppFontSizes.xl, color: AppColors.white)),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded outlined input with a leading icon and hint text (auth screens).
InputDecoration authFieldDecoration(BuildContext context, String hint, IconData icon,
    {Widget? suffix}) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );
  final scheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.bodyLarge.copyWith(color: scheme.onSurfaceVariant),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 14, right: 10),
      child: Icon(icon, size: 24, color: scheme.onSurfaceVariant),
    ),
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(vertical: 18),
    enabledBorder: border(AppColors.fieldBorder),
    border: border(AppColors.fieldBorder),
    focusedBorder: border(AppColors.primary, 1.5),
  );
}

/// Pale gradient + soft corner waves behind auth screens.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.splashBgTop, AppColors.splashBgBottom],
              ),
        color: isDark ? Theme.of(context).colorScheme.surface : null,
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: BrandCornerWaves(soft: true)),
          child,
        ],
      ),
    );
  }
}
