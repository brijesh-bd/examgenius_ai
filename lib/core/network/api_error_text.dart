import '../../l10n/app_localizations.dart';
import 'api_client.dart';

/// Localized, student-friendly text for any error from a repository call.
String apiErrorText(AppLocalizations l10n, Object? error) {
  if (error is ApiException) {
    if (error.isNetwork) return l10n.errorNetwork;
    if (error.statusCode == 503) return l10n.errorAiBusy;
    if (error.statusCode == 401) return l10n.errorSessionExpired;
  }
  return l10n.errorGeneric;
}
