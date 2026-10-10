// CI stand-in for lib/firebase_options.dart, which `flutterfire configure`
// generates locally and .gitignore keeps out of the repo. Lets analyze, test
// and debug builds compile without real Firebase credentials.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'ci-stub',
        appId: '1:000000000000:android:0000000000000000',
        messagingSenderId: '000000000000',
        projectId: 'ci-stub',
      );
}
