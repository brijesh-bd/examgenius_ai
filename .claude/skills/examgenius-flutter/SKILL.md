---
name: examgenius-flutter
description: Conventions for building features in the ExamGenius AI Flutter app (government exam prep, Riverpod + GoRouter + gen-l10n, clean architecture). Use when adding or changing any screen, provider, repository, route, localized string, or theme in this project, or when starting a new roadmap phase (AI generator, mock test, results, analytics, subscription, offline, notifications).
---

# ExamGenius AI — Flutter feature conventions

Android-first Flutter app (iOS later) for RRB / SSC / Banking exam prep. **Backend is wired**: `../examgenius_backend` (Node/Express, MongoDB `examgenius`, Google Gemini — key only in backend `.env`). Every repository has an `Api…Repository` (Dio, `core/network/api_client.dart`) and a `Mock…Repository`; providers pick Api by default and Mock under `flutter test` / `--dart-define=USE_MOCK_BACKEND=true` (`useMockBackendProvider`). JWT in `TokenStore` (flutter_secure_storage). Base URL: `--dart-define=API_BASE_URL=…` (defaults: Android emulator `10.0.2.2`, web/desktop `localhost`). `test/backend_contract_test.dart` runs the real repositories against a running server (auto-skips otherwise).

## Stack (do not swap)
- State: **flutter_riverpod 3** — `Notifier`/`AsyncNotifier` + `NotifierProvider`/`FutureProvider`. No `StateProvider`, no Bloc, no code-gen.
- Routing: **go_router** — paths in `lib/core/routes/app_routes.dart`, routes in `app_router.dart`. Bottom tabs = `StatefulShellRoute.indexedStack` (`features/shell/main_shell.dart`).
- i18n: **gen-l10n** — `lib/l10n/app_en.arb` (template) + `app_hi.arb`. Access via `context.l10n` (`core/utils/l10n_ext.dart`).
- Prefs: `sharedPreferencesProvider` (overridden in `main.dart`). Non-sensitive data only.
- Theme: `core/theme/app_theme.dart` (M3, seed `AppColors.primary`), light + dark.

## Feature layout
```
lib/features/<feature>/
  domain/        entities (+ fromJson/toJson matching backend contract), repository interface, failures
  data/          Mock<Name>Repository now; Api<Name>Repository (Dio) later
  presentation/
    providers/   <feature>_providers.dart — repository provider + Notifiers
    screens/     full pages (ConsumerWidget / ConsumerStatefulWidget)
    widgets/     feature-specific widgets
```
Shared widgets live in `lib/core/widgets/app_widgets.dart` (`ResponsiveCenter`, `PrimaryButton`, `SectionHeader`, `Skeleton`, `StateMessage`, `AppLogo`) — reuse before creating new ones.

## Rules
1. **No business logic in widgets.** Widgets read providers and call notifier methods. Validation lives in `core/utils/validators.dart` and returns `ValidationError` enums, mapped to text with `.message(l10n)`.
2. **Every user-visible string goes in BOTH ARB files**, then run `flutter gen-l10n`. Placeholders need `@key` metadata in `app_en.arb` only. Never hardcode English in UI (exam names from the catalog are the exception).
3. **Exams are data, not code.** Never hardcode an exam list in UI; read `examCatalogProvider`. Category styling uses `categoryStyle()` with a fallback for unknown ids.
4. **Repositories are swapped at the provider**, never in screens. New backend client = new class implementing the same interface.
5. **Every async view handles loading (Skeleton), error (StateMessage + retry) and empty states.**
6. **Responsive:** wrap page content in `ResponsiveCenter`; use `LayoutBuilder` for grids; the shell switches to `NavigationRail` ≥ 840 px.
7. **Accessibility:** tooltips on icon buttons, `Semantics(header: true)` via `SectionHeader`, 48 dp min touch targets.
8. **Security:** never put AI API keys, JWTs or passwords in SharedPreferences or in the app. JWTs → `flutter_secure_storage` when the API lands. AI calls go only through the backend.
9. Unbuilt modules route to `context.openComingSoon(title)` — replace those calls when the module ships.
10. Use `withValues(alpha:)` (not `withOpacity`), `CardThemeData`, `DropdownButtonFormField.initialValue` — the analyzer flags the deprecated forms.
11. **Design tokens only.** Colours in `core/theme/app_colors.dart`, font sizes/weights/text styles (Poppins via google_fonts, bundled in `assets/fonts/`) in `core/theme/app_typography.dart`. No raw `Color(0x…)` or numeric `fontSize` outside `core/theme/`.
12. **Never reveal answers before submission.** In-test models (`PracticeQuestion`) carry no answer/explanation; scoring happens in the repository (backend). Answers arrive only in `PracticeResult` after submit.
13. **Snackbars with an action** must set `persist: false`, or they stay on screen and cover bottom buttons.

## Adding a feature — checklist
1. Domain entity + repository interface (JSON keys = backend contract).
2. Mock repository with realistic latency (`Future.delayed`).
3. Providers file.
4. Screens/widgets using shared components; strings in both ARBs.
5. Route constant + `GoRoute` (inside a shell branch if it's a tab).
6. Tests: unit tests for pure logic; widget test for the main flow (see `test/app_flow_test.dart` for the `pumpApp` pattern with mocked SharedPreferences).
7. Verify: `flutter gen-l10n && flutter analyze && flutter test` — all must be clean before moving to the next phase.

## Mock auth behaviour
Any valid Indian mobile (starts 6–9, 10 digits) + password ≥ 8 chars logs in; password `wrongpass` simulates invalid credentials.

## Navigation
Bottom tabs: Home · Practice (placeholder) · **Saved** (My Saved Practice, `/saved`) · Analytics (placeholder). Profile opens from the Home avatar. Auth: login (email or mobile, remember me, mobile OTP = coming soon), register, forgot password.

## Practice flow (`features/practice_test`)
Generate → `PracticeTestScreen` (one question at a time, palette, countdown, Submit gated on all answered; timer expiry auto-submits) → submit confirmation dialog → `PracticeResultScreen` (scorecard, charts, topic analysis) → `AnswerReviewScreen` (filters, explanations, maths steps). Retry / Practice Again use `RetrySource` (new session; original attempt unchanged). Save Practice → `SavedPracticeRepository` (mock persists to prefs). Marking: +1 / −0.25 / 0, accuracy = correct ÷ attempted.

## Roadmap status
Done: Phase 1 (architecture), 2 (splash/onboarding), 3-UI (login/register/forgot password, mock), 4 (dashboard), 5 (exam selection), 6 (syllabus/subjects/topics with single/multiple selection), 7-UI (AI generator, mock bank in `features/question_generator`), post-generation Screens 1–6 (practice test, submit confirmation, scorecard, answer review, save practice, My Saved Practice), 11-partial (EN/HI UI).
Done (backend): auth (register, login by email/mobile, forgot-password endpoint), Gemini generation, practice sessions/submit/retry, saved practice, dashboard summary — all in MongoDB.
Next: Screen 7 Mistake Notebook → mock test engine (Home "Mock Tests" card is coming soon) → email/SMS provider (password reset, mobile OTP) → HTTPS deploy. Backend contracts: `POST /api/v1/questions/generate` (no answers), `POST /api/v1/practice/:sessionId/submit`, `POST /api/v1/practice/retry`, `GET|POST|DELETE /api/v1/practice/saved`. Repositories are switched at their providers (Api vs Mock).
