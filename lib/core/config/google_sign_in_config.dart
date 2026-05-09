/// Google Sign-In — **Android** usually needs this so Firebase gets an `idToken`.
///
/// Where to find it:
/// 1. [Firebase Console](https://console.firebase.google.com/) → your project → **Project settings** (gear).
/// 2. **General** tab → scroll to **Your apps** → pick the **Web** app  
///    (add one with “</>” if missing).
/// 3. Under **SDK setup and configuration**, copy **Web client ID**  
///    (looks like `123456789-xxxx.apps.googleusercontent.com`).
///
/// Or: [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services →
/// **Credentials** → OAuth 2.0 Client IDs → type **Web application**.
///
/// Paste that full string below (between the quotes). Leave empty only while testing
/// email/password only — Google button may fail on Android without this.
const String kGoogleOAuthWebClientId = '';
