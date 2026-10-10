# Firestore rules tests

Emulator tests for [`../firestore.rules`](../firestore.rules). CI runs them on every PR.

```bash
cd firestore-tests
npm ci
npm test   # starts the Firestore emulator, runs rules.test.mjs, stops it
```

Requires Node 20+ and Java 21+ (for the emulator). Uses the `demo-blessed-bible`
project id, so it never touches the real Firebase project.

Deploy rule changes with `firebase deploy --only firestore:rules` from the repo root.
