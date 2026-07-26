# Project Rules & Workflow

## 1. Always Verify Build Before Done
After making ANY code change, before reporting a task or prompt as complete, the agent/developer MUST:
1. Run `flutter analyze` and confirm zero errors (fix any errors found).
2. Confirm the project compiles cleanly and hot-reloads without build errors.
3. Verify the specific feature changed actually works, and that existing screens (Home, Read, Search, Study, Settings) and navigation are not broken.

Only report a task as complete once the build is green and nothing is broken.

## 2. Commit After Every Green Build
- Immediately after verifying a build is green (`flutter analyze` zero errors + clean compile), commit the changes to git.
- Keep commits atomic, clean, and descriptive of the feature or refactor accomplished.
- This prevents regressions and protects working states from getting lost.

## Layout & Symmetry
- SYMMETRY IS DEFAULT. Unless I explicitly say otherwise, all layouts must be mathematically balanced: split space into clean halves, thirds, or quarters. Elements in a row must share one level baseline (identical vertical centers). Side elements must have equal insets from their screen edges. Paired buttons must be equal size and evenly spaced. Never leave lopsided margins, uneven gaps, or misaligned baselines.
- When laying out any new row, group, or set of controls, choose halves / thirds / quarters proportions by default and align to a shared grid.

## UI Change Preservation
- PRESERVE, DON'T OVERWRITE. When I request a change to existing UI or system behavior, do NOT silently replace the old behavior. First judge whether the change is SIGNIFICANT (a layout mode, scroll behavior, navigation flow, view style, or any behavior a user might prefer the old version of) or MINOR (a small spacing, color, label, or one-off fix).
- For SIGNIFICANT changes: preserve the previous behavior as a user-selectable option. If a related setting already exists (e.g. a Reading View, Navigation Depth, or Font setting), ADD the new choice to that existing setting automatically. If no related setting exists, ASK me: "Do you want a setting to toggle between the old and new version?" before proceeding. Default the setting to whichever version I indicated I prefer.
- For MINOR changes: just make the change; no toggle needed.
- NEVER completely rewrite or delete existing UI/system behavior in a way that makes the old version unrecoverable without a toggle or my explicit approval. When in doubt, ask before destroying the old behavior.
- Group related toggles under their logical Settings section (Reading, Navigation, Typography, etc.) rather than scattering them, to keep Settings clean.

## Build Verification (Mandatory)

- BUILD IS THE REAL TEST, NOT ANALYZE. `flutter analyze` passing does NOT mean the app compiles. Multiple changes have passed analyze while `flutter build` failed (invalid API usage like EdgeInsets.bottom / wrong widget parameters, Gradle/Android config like core library desugaring, WidgetRef vs BuildContext). analyze checks Dart lint/types; the build catches real compile + platform errors that analyze misses.
- NEVER report a task as done, and NEVER commit, without running an ACTUAL BUILD for the target and confirming it succeeds. Run BOTH:
  1. `flutter analyze` (must be ZERO errors), AND
  2. `flutter build apk --debug` (or the iOS simulator build) — must complete; paste the "✓ Built ..." line as proof.
- If the build fails, fix it and re-run before committing. Do not claim success based on analyze alone.
- When using invalid or uncertain Flutter/Dart APIs, verify the constructor/parameter names against the real Flutter API before writing them — do not invent parameter names (e.g. EdgeInsets uses .only/.all/.symmetric/.fromLTRB, not .bottom; TextButton.icon uses icon:/label:/onPressed:, not onIcon:).
