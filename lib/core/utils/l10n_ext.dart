import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import 'validators.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension ValidationErrorText on ValidationError {
  String message(AppLocalizations l10n) => switch (this) {
        ValidationError.required => l10n.errorRequired,
        ValidationError.mobile => l10n.errorMobile,
        ValidationError.password => l10n.errorPassword,
        ValidationError.passwordMatch => l10n.errorPasswordMatch,
        ValidationError.email => l10n.errorEmail,
        ValidationError.emailOrMobile => l10n.errorEmailOrMobile,
        ValidationError.name => l10n.errorName,
        ValidationError.terms => l10n.errorTerms,
      };
}
