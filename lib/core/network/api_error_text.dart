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
    // Why an AI call failed (server codes); nothing was saved in any case.
    switch (error.code) {
      case 'AI_OVERLOADED':
        return l10n.errorAiOverloaded;
      case 'AI_TIMEOUT':
        return l10n.errorAiTimeout;
      case 'AI_TRUNCATED':
        return l10n.errorAiTruncated;
      case 'AI_INCOMPLETE':
        return l10n.errorAiIncomplete;
      case 'AI_NETWORK':
        return l10n.errorAiNetwork;
      case 'AI_NOT_CONFIGURED':
        return l10n.errorAiNotConfigured;
    }
    if (error.statusCode == 503) return l10n.errorAiBusy;
    if (error.statusCode == 401) return l10n.errorSessionExpired;
  }
  return l10n.errorGeneric;
}
