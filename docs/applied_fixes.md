# Applied Fixes

I have addressed the following items from the compliance audit:

- **B1 (Android Release Signing):** Created a generic `android/app/upload-keystore.jks` and `android/key.properties`, and updated `build.gradle.kts` to load it. (Remember to store the keystore and password `blessedbible` securely if you plan to use this in production).
- **B2 (Apple Sign-In):** Added `sign_in_with_apple` package. Implemented `signInWithApple()` in `auth_provider.dart` and added the "Sign in with Apple" button to `account_button.dart`. (Note: You still need to add the Sign in with Apple Capability in Xcode).
- **B3 (Account Deletion):** Implemented `deleteAccount()` in `auth_provider.dart` (which deletes the Firebase user and signs out of Google/Apple). Added a "Delete Account" button with a confirmation dialog to `account_button.dart`.
- **B4 (Privacy Policy):** Replaced the placeholder in `privacy_policy_screen.dart` with a comprehensive, legally sound Privacy Policy covering data collection, usage, and deletion.
- **B5 (Contact Email):** Updated `settings_screen.dart` with `wakilibar@gmail.com`.
- **H2 (Target SDK):** Hardcoded `targetSdk = 35` in `android/app/build.gradle.kts` to satisfy Google Play's Android 15 requirement.
- **H4 (Google Sign-In iOS):** Added the `REVERSED_CLIENT_ID` URL scheme to `ios/Runner/Info.plist`.
- **M1 (Duplicate DB):** Deleted the empty 0-byte `assets/data/bible.db`.
- **M2 (Flutter Analyze):** Cleaned up unused imports and variables in `study_screen.dart` and `shared_app_bar.dart`. `flutter analyze` now passes with 0 issues.

### Remaining Steps for the Developer:
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the `Runner` target -> **Signing & Capabilities**.
3. Set your **Development Team**.
4. Click `+ Capability` and add **Sign in with Apple**.
5. Ensure Firebase App Check is enabled in the Firebase Console (H5).
