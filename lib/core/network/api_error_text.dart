import '../../l10n/app_localizations.dart';
import 'api_client.dart';

/// Localized, student-friendly text for any error from a repository call.
String apiErrorText(AppLocalizations l10n, Object? error) {
  if (error is ApiException) {
    if (error.isNetwork) return l10n.errorNetwork;
    // Gemini quota used up: nothing was saved or counted; try later.
    if (error.code == 'AI_QUOTA_EXHAUSTED') return l10n.errorAiQuota;
    // Checked against the coverage list and still incomplete (nothing saved).
    if (error.code == 'CONTENT_INCOMPLETE') return l10n.errorContentIncomplete;
    if (error.statusCode == 503) return l10n.errorAiBusy;
    if (error.statusCode == 401) return l10n.errorSessionExpired;
  }
  return l10n.errorGeneric;
}
