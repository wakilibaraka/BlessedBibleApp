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
