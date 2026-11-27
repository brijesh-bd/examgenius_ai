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
Bottom tabs: Home · Practice (placeholder) · **Library** (My Learning Library, `/saved`, category libraries at `/saved/c/:category`) · Analytics (placeholder). Profile opens from the Home avatar. Auth: login (email or mobile, remember me, mobile OTP = coming soon), register, forgot password.

## Practice flow (`features/practice_test`)
Generate → `PracticeTestScreen` (one question at a time, palette, countdown, Submit gated on all answered; timer expiry auto-submits) → submit confirmation dialog → `PracticeResultScreen` (scorecard, charts, topic analysis) → `AnswerReviewScreen` (filters, explanations, maths steps). Retry / Practice Again use `RetrySource` (new session; original attempt unchanged). Every generated set is saved automatically to the Library (`features/library`, `LibraryRepository`); the scorecard shows "Open Library" instead of a Save button. Practice Again on a Library set = `LibrarySetSource` (same questions, new attempt). Library screens watch `libraryRevisionProvider` — bump it when a set or attempt changes elsewhere. Library data is always queried per category (Railway / SSC / Banking never mix). Marking: +1 / −0.25 / 0, accuracy = correct ÷ attempted.

## AI Study Notes (`features/study_notes`)
**Redesigned (one screen):** `/notes` = `NotesStudioScreen`, with state in `notesStudioProvider`:
- **Flow:** category chips → exam chips → subject chips → `ConceptTree` single-pick (`picked`, search, any level) or topic chips for flat subjects → language → topic overview (`topicSummaryProvider` → `POST /notes/topic-summary`, shared cache `topic_summaries`, no auto-retry) → **Generate complete notes** (`NotesRequest.complete` → `coverage: 'complete'`).
- **No difficulty or section pickers.** The server writes every section for the whole sub-tree, using the subject template guide, a 65k token budget and a completeness floor.
- **Old links still work:** `/notes/exams|topics|concepts|create/...` open the same screen preselected.
- **Generation UI:** progress steps by elapsed time. Failures show `apiErrorText` codes (AI_OVERLOADED, AI_TIMEOUT, AI_TRUNCATED, AI_INCOMPLETE, AI_NETWORK, AI_NOT_CONFIGURED, AI_QUOTA_EXHAUSTED). Retry reuses the same request, so the same requestKey is sent.
- **Server side:** one in-flight generation per user × requestKey, and the quota is counted only when a note is created. Gemini moves to the next model on per-model quota (free tier) and stops on project-wide quota. App timeout `kNotesTimeout` = 6 min.

Previous flow (for history): `/notes` category → `/notes/exams/:categoryId` → `/notes/topics/:examId` → `/notes/create/:examId/:topicId` (language, level, 12 section chips) → `/notes/view/:noteId` (TOC, collapsible sections, flowcharts, CustomPaint graphs, tables, code, MCQs with hidden answers). Backend: `POST /notes/generate` (Gemini, validated by `validateNoteContent`, auto-saved in `study_notes`, requestKey idempotent, never overwrites), `GET /notes?category=…`, `GET|PATCH|DELETE /notes/:id` (PATCH: personalNote, bookmarked). No AI key → 503, never placeholder notes. Bump `notesRevisionProvider` when notes change. Library: "My Study Notes" section on the Library home (counts from `GET /notes/summary`) → `/saved/notes/:category` (`CategoryNotesScreen`: search, filters exam/subject/topic/language/level/date via `GET /notes/facets` + `GET /notes`, sort, paging). Filter chips/sheets are shared in `library/presentation/widgets/filter_picker.dart`. Phase 8: note screen has bookmark toggle, personal note (bottom sheet), delete (confirm) via `noteActionsProvider` (server-confirmed, bumps `notesRevisionProvider`); category notes have All / Bookmarked / Personal notes tabs (`NotesView`, `bookmarked` / `hasPersonalNote` query); Quick revision + Flashcards (`revision_screens.dart`, built from saved content, no AI). Practice History = `GET /library/sets/:id/attempts` bottom sheet → scorecard. Not built yet: Ask AI, explain simpler, compare concepts, mind map, read aloud, PDF export, per-section bookmarks.

## Learning path (AI Study Notes)
Backend `topicUnits` in `src/data/syllabus.js` splits 20 broad topics into curated units (id `<topicId>.<unit>`); `learningItems`/`findLearningItem` in examService build a subject path from the syllabus (nothing duplicated). `GET /learning-path/:examId/:subjectId` (items with completed/current/upcoming, latestNoteId, notesCount), `PUT /learning-path/:examId/items/:itemId` {completed}; collection `learning_progress` (unique userId+examId+itemId). Notes `content.nextTopics` = `[{id,name}]` set by the server from the path (AI suggestions discarded); old notes have strings (`NoteNextTopic.id == null`, not tappable). App: `LearningPathScreen` (`/notes/path/:examId/:subjectId`), `NotePathPanel` + `NextTopicsList` on the notes page, Create Notes takes `NotesPrefill` (language, level) as route extra. Completion only via "Mark as completed".

## Outline sections (backend done; Flutter screens pending)
Curated outlines (chapters → sections) in backend `src/data/outlines/` attach to learning units; only `status: approved` is served (`NOTES_SHOW_DRAFT_OUTLINES=true` shows drafts for review). `GET /notes/outlines/:examId/:unitId?language&mode` (section states completed/generated/failed/pending, chapter progress, `coverageComplete`, `continue`), `POST /notes/sections/generate` (student copy → shared `section_cache` → new AI; `source` saved/cache/ai; `regenerate` = new version), `PUT /notes/sections/progress`. Modes quick/detailed/complete with quality rules (`checkSection`). Quota (`NotesQuota`, `ai_generation_log`) counts only successful new AI generations. Gemini calls via `GeminiJsonClient` (one retry for brief transient errors, none for permanent errors or long quota waits, logs fallback). Notes models `GEMINI_NOTES_MODELS` (no Flash-Lite). Cache maintenance: `npm run notes-cache`.

## Chapter Builder (AI chapter index)
A topic without a curated outline gets `NO_OUTLINE`. The outline screen then offers "Build chapter index" (`chapterIndexProvider` calls `POST /notes/outlines/:examId/:unitId/index` with an optional `stage`).
- **Index building:** the backend `outlineGenerator.js` builds the index from the verified syllabus scope (concept-tree nodes for that exam and stage). `checkIndex` validates it: snake_case ids, no duplicate parts, page references removed, basic→advanced order flagged, scope gaps flagged.
- **Review:** the index is saved as a **draft** in `ai_outlines` (`AiOutlineStore`). Students get `OUTLINE_PENDING_REVIEW` until an admin approves it. Admin routes: `GET /admin/outlines?status=draft` and `POST /admin/outlines/:unitId/review` with `{action: approve|reject, outline?, comment?}`. Editing an index bumps its version.
- **Precedence:** curated outlines always win.
- **Learning parts:** approved AI indexes run through the existing section pipeline unchanged. Parts carry `level`, `concepts` and `includes`, which reach the section prompt (`partPlan`). Curated prompts and the shared cache are unaffected.
- **Outline response:** includes `completionStatus` (`NOT_STARTED` / `IN_PROGRESS` / `LEARNING_COMPLETED`), `revisionPlan`, `overview`, `objectives` and `source` (`curated` / `ai_reviewed`).
- **App display:** the app shows the "AI-built index · reviewed" label, and shows the revision plan once every part is completed.

## Roadmap status
Done: Phase 1 (architecture), 2 (splash/onboarding), 3-UI (login/register/forgot password, mock), 4 (dashboard), 5 (exam selection), 6 (syllabus/subjects/topics with single/multiple selection), 7-UI (AI generator, mock bank in `features/question_generator`), post-generation Screens 1–6 (practice test, submit confirmation, scorecard, answer review, save practice, My Saved Practice), 11-partial (EN/HI UI).
Done (backend): auth (register, login by email/mobile, forgot-password endpoint), Gemini generation, practice sessions/submit/retry, saved practice, dashboard summary — all in MongoDB.
Next: Screen 7 Mistake Notebook → mock test engine (Home "Mock Tests" card is coming soon) → email/SMS provider (password reset, mobile OTP) → HTTPS deploy. Backend contracts: `POST /api/v1/questions/generate` (no answers), `POST /api/v1/practice/:sessionId/submit`, `POST /api/v1/practice/retry`, `GET /api/v1/library/summary`, `GET /api/v1/library/sets?category=…` (filters: examId, subjectId, topicId, difficulty, language, from, to, q, sort, page), `GET /api/v1/library/facets?category=…`, `GET|DELETE /api/v1/library/sets/:id`, `POST /api/v1/library/sets/:id/start`. Generate accepts `requestKey` (no duplicate sets on retries). Legacy `/practice/saved` stays for old builds only. Repositories are switched at their providers (Api vs Mock).
