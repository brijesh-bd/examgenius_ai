import 'package:flutter/material.dart';

import '../../../../core/network/api_error_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/student_user.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  // Off until the first submit; then each field re-checks as the user types,
  // so an error disappears as soon as the field becomes valid.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _examId;
  bool _agreed = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    for (final c in [_name, _mobile, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState!.validate();
    setState(() {
      _showTermsError = !_agreed;
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!valid || !_agreed) return;
    final email = _email.text.trim();
    await ref
        .read(authFormProvider.notifier)
        .register(
          RegisterRequest(
            name: _name.text,
            mobile: _mobile.text.trim(),
            password: _password.text,
            targetExamId: _examId!,
            email: email.isEmpty ? null : email,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final status = ref.watch(authFormProvider);
    final catalog = ref.watch(examCatalogProvider);
    ref.listen(authFormProvider, (_, next) {
      if (next.hasError && !next.isLoading) showAuthError(context, next.error!);
    });

    return AuthScaffold(
      showBack: true,
      title: l10n.createAccount,
      subtitle: l10n.registerSubtitle,
      children: [
        Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: AutofillGroup(
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => Validators.name(v)?.message(l10n),
                ),
                const SizedBox(height: 16),
                MobileField(
                  controller: _mobile,
                  validator: (v) => Validators.mobile(v)?.message(l10n),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) => Validators.optionalEmail(v)?.message(l10n),
                ),
                const SizedBox(height: 16),
                // Exams come from the server: show loading, and an error with
                // Retry if the list could not be fetched (never an empty list).
                DropdownButtonFormField<String>(
                  initialValue: _examId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.targetExam,
                    prefixIcon: const Icon(Icons.school_outlined),
                    suffixIcon: catalog.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    errorText: catalog.hasError && !catalog.isLoading
                        ? apiErrorText(l10n, catalog.error)
                        : null,
                    errorMaxLines: 3,
                  ),
                  items: [
                    for (final cat in catalog.value ?? const [])
                      for (final exam in cat.exams)
                        DropdownMenuItem(
                          value: exam.id,
                          child: Text(exam.name),
                        ),
                  ],
                  onChanged: catalog.hasValue ? (v) => setState(() => _examId = v) : null,
                  validator: (v) => v == null ? l10n.errorRequired : null,
                ),
                if (catalog.hasError && !catalog.isLoading)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: () => ref.invalidate(examCatalogProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _password,
                  label: l10n.password,
                  validator: (v) => Validators.password(v)?.message(l10n),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirm,
                  label: l10n.confirmPassword,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.confirmPassword(
                    v,
                    _password.text,
                  )?.message(l10n),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _agreed,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(l10n.agreeTerms, style: theme.textTheme.bodyMedium),
          subtitle: _showTermsError && !_agreed
              ? Text(
                  l10n.errorTerms,
                  style: TextStyle(color: theme.colorScheme.error),
                )
              : null,
          onChanged: (v) => setState(() => _agreed = v ?? false),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: l10n.createAccount,
          loading: status.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.alreadyHaveAccount),
            TextButton(onPressed: () => context.pop(), child: Text(l10n.login)),
          ],
        ),
      ],
    );
  }
}
