# Phase 6: UX Sweep Plan

Each chunk ends with `flutter analyze` clean, `flutter test` green, one commit, and a push to the working branch. A PR is opened after chunk 2 and updated as chunks land; it merges when CI is green at a natural checkpoint (after chunks 2, 5 and 8).

| # | Chunk | What | Done when |
|---|---|---|---|
| 1 ✅ | Localization foundation + onboarding | gen-l10n, 6 languages (en, fr, it, ro, sw, tl), language picker in Settings, 4-step onboarding | Pushed (d3e7066) |
| 2 ✅ | Translate every screen | All UI strings into ARB fragments (`tool/l10n/parts/`), plurals/placeholders, locale-aware dates | No English literals left in `lib/ui`; a guard test fails CI if new ones appear |
| 3 | Non-UI strings | Notifications, reminders, toasts from services, home widget labels, share text, error messages, plan/day labels | Reminders and the widget show in the chosen language |
| 4 | Onboarding completion | Optional reminders step (permission asked after explaining why), optional sign-in step ("works fully offline"), resume after app kill | Widget tests for skip/back/resume |
| 5 | Theme tokens | `ThemeExtension` for semantic colours, spacing, radii and text styles; replace `Color(0x…)`/`Colors.*`/`fontSize:` screen by screen (reader → settings → the rest) | Hard-coded counts down to a justified list; a lint script reports regressions |
| 6 | Accessibility | Semantic labels on icon buttons and gestures, button alternatives for swipe-only actions, 48 dp touch targets, largest-text pass, reduced motion and reduced transparency (blur fallback) | Flutter `meetsGuideline` tests (tap target, labels, contrast) on key screens |
| 7 | Consistency | One empty/loading/error pattern, one confirm-and-undo pattern for deletes, one verse-reference format, sentence case, US English | Shared widgets used everywhere; checklist section 9 ticked |
| 8 | Goldens + device checklist | Golden tests for key screens in light/sepia/dark/OLED and at large text; a device test script for you | Goldens in CI; script in `docs/` |

Out of scope here: iOS and Apple sign-in (Phase 5), flavors/CD/obfuscation (Phase 7).

Owner tasks that can happen any time: native-speaker review of Swahili and Tagalog (`tool/l10n/parts/*.json`), GitHub Pages, branch protection, App Check enforcement, Play Data safety form, Romanian BTF permission.
