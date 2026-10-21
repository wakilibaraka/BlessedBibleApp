# Android: Google sign-in setup and release checks

Google sign-in only works for a build whose **signing certificate** is
registered in Firebase. A build from Google Play is re-signed by Google, so its
certificate differs from your debug and upload keys. Register all three.

Project: `blessedbibleapp`. Android app: `com.baraka.bibleapp`.

## 1. Collect the fingerprints

| Key | Where to get SHA-1 and SHA-256 |
| --- | --- |
| Debug | `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android` |
| Upload | `keytool -list -v -keystore <your upload .jks> -alias <alias>` (the key in `android/key.properties`) |
| Play App Signing | Play Console → the app → **Test and release → App integrity → App signing** → *App signing key certificate* |

## 2. Firebase console

1. **Project settings → Your apps → Android (`com.baraka.bibleapp`) → Add fingerprint**: add SHA-1 and SHA-256 for all three keys above.
2. **Authentication → Sign-in method → Google**: enabled, with a support email set.
3. **Download `google-services.json`** again (it only contains the web OAuth client after the fingerprints are added) and put it in `android/app/`. It stays gitignored. The `oauth_client` list must not be empty; if it is, the fingerprints or provider step was missed.
4. Run `flutterfire configure` if `lib/firebase_options.dart` is missing or stale.

## 3. Build and ship to the internal track

```
flutter build appbundle --release
```

Upload the `.aab` to **Internal testing**, add yourself as a tester, and install
from the Play link. Do not sideload for this test: a sideloaded release is
signed with the upload key, not the Play key, and hides the problem.

## 4. Run the checks

Work through section 6 of `docs/DEVICE_TEST_CHECKLIST.md` on that install.

If sign-in says "Sign-in isn't set up correctly" the report in Crashlytics
carries the underlying code: `google-clientConfigurationError` or
`google-providerConfigurationError` mean a missing fingerprint or provider;
`invalid-credential` / `app-not-authorized` point at the OAuth client.

## 5. App Check, before enforcing it

Do this only after step 4 passes, in this order:

1. **App Check → Apps → Android**: register with **Play Integrity** and add the Play App Signing SHA-256.
2. Install the Play build, sign in, add data, and confirm it syncs (Firestore *metrics* in the App Check page should show verified requests).
3. Only then turn on enforcement for Firestore. If sync starts failing with `permission-denied` after enforcement, turn it off again and recheck step 1.
4. Debug builds need their debug token registered under *Manage debug tokens* (printed in the device log).
