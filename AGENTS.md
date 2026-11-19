# Agent instructions

## Always base work on the latest `main`

`main` is the only long-lived branch. Before writing any code:

1. `git fetch origin`
2. Start from the remote, never from a local or cached branch:
   `git switch -c <topic> origin/main`. Never branch from an `archive/*` tag.
3. Prove you are current before starting, and again before pushing:
   `git rev-list --left-right --count origin/main...HEAD` (the left number must
   be 0 when you begin) and
   `gh api repos/wakilibaraka/BlessedBibleApp/compare/main...<branch>`.
4. If `origin/main` moved while you worked, rebase onto it and re-run the gates.
   Do not merge stale code forward.
5. Deleted branches are kept as `archive/<branch-name>` tags. They are history
   only: recover from them if you must, never start from them.

If your checkout reports that it is behind `origin/main`, stop and rebase before
changing anything. Work that started from an outdated base gets thrown away.

## Gates, in CI order

The toolchain is pinned in `.fvmrc`; always run Flutter through FVM
(`fvm flutter ...`) so the SDK matches CI.

1. `flutter pub get --enforce-lockfile`
2. `dart format --output=none --set-exit-if-changed lib test`
3. `flutter analyze --fatal-infos`
4. `flutter test`

Golden images compare with a 1.5% anti-aliasing tolerance, because Linux CI and
macOS rasterize edges differently; see `test/goldens_test.dart`.

## Branch housekeeping

Keep branches short-lived: open the PR, merge it, delete the branch (the merge
commit keeps it recoverable). No permanent `claude/*`, `release/*`, `backup/*`
or `freebuff/*` refs.
