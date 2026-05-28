import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/config/google_sign_in_config.dart';
import '../../core/platform/android_signing_info.dart';
import '../../core/database/database_helper.dart';
import '../../core/preferences/app_preferences.dart';
import '../../data/services/user_profile_service.dart';
import '../bootstrap/local_data_refresh.dart';

/// Firebase Auth gate + post-login local DB binding & Firestore profile sync.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AppPreferences prefs,
    required bool firebaseAuthEnabled,
  })  : _prefs = prefs,
        _firebaseAuthEnabled = firebaseAuthEnabled {
    if (_firebaseAuthEnabled) {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
        notifyListeners();
      });
    }
  }

  final AppPreferences _prefs;
  final UserProfileService _profileService = UserProfileService();
  final bool _firebaseAuthEnabled;
  StreamSubscription<User?>? _authSub;

  bool get firebaseAuthEnabled => _firebaseAuthEnabled;

  User? get firebaseUser =>
      _firebaseAuthEnabled ? FirebaseAuth.instance.currentUser : null;

  bool get isLoggedIn =>
      !_firebaseAuthEnabled || FirebaseAuth.instance.currentUser != null;

  Future<void> handleSuccessfulLogin(BuildContext context, User user) async {
    final bound = _prefs.boundLocalDataFirebaseUid;
    final onboardingDone = _prefs.onboardingCompleted;

    if (bound != null && bound != user.uid) {
      await DatabaseHelper.instance.wipeLocalDatabase();
    } else if (bound == null && onboardingDone) {
      // Legacy installs upgraded before Firebase: ledger wasn't keyed — tie cleanly.
      await DatabaseHelper.instance.wipeLocalDatabase();
    }

    await _prefs.setLegalTermsAccepted(true);
    await _prefs.setBoundLocalDataFirebaseUid(user.uid);
    try {
      await _profileService.syncRemoteProfile(user);
    } catch (_) {
      // Firestore may be offline or rules misconfigured — local ledger still works.
    }
    if (context.mounted) {
      await refreshAllLocalDataCaches(context);
    }
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  }) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Android: prefer [GoogleSignIn.serverClientId] (Web OAuth client ID) so Firebase
  /// gets a non-null `idToken`. When [kGoogleOAuthWebClientId] is empty, the
  /// google-services plugin's `default_web_client_id` is used on Android.
  GoogleSignIn _googleSignIn() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final webId = kGoogleOAuthWebClientId.trim();
      if (webId.isNotEmpty) {
        return GoogleSignIn(
          scopes: const ['email', 'profile'],
          serverClientId: webId,
        );
      }
      return GoogleSignIn(scopes: const ['email', 'profile']);
    }
    final webId = kGoogleOAuthWebClientId.trim();
    if (webId.isNotEmpty) {
      return GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: webId,
      );
    }
    return GoogleSignIn(scopes: const ['email', 'profile']);
  }

  Future<String> _androidSigningHint() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return '';
    }
    final sha1 = await AndroidSigningInfo.getSigningSha1();
    if (sha1 == null || sha1.isEmpty) return '';
    return ' App signing SHA-1: $sha1 — add this to Firebase if missing, '
        'then download new google-services.json and rebuild.';
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = _googleSignIn();
    GoogleSignInAccount? account;
    try {
      account = await googleSignIn.signIn();
    } on PlatformException catch (e) {
      final details = '${e.code} ${e.message ?? ''}';
      if (e.code == 'sign_in_failed' ||
          details.contains('10') ||
          details.contains('DEVELOPER_ERROR')) {
        final signingHint = await _androidSigningHint();
        throw FirebaseAuthException(
          code: 'google-android-config',
          message: 'Google Sign-In failed (code 10).$signingHint '
              'Check Play Console → Setup → App integrity → App signing key SHA-1 '
              'is in Firebase, and Authentication → Google → Web SDK is configured.',
        );
      }
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Google sign-in failed.',
      );
    }
    if (account == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-aborted',
        message: 'Google sign-in was cancelled.',
      );
    }
    final auth = await account.authentication;
    if (auth.idToken == null) {
      throw FirebaseAuthException(
        code: 'google-missing-id-token',
        message: 'Google did not return an ID token (Firebase needs it). '
            'Set kGoogleOAuthWebClientId in '
            'lib/core/config/google_sign_in_config.dart to your Firebase '
            'Web client ID (Project settings → Web app). '
            'If google-services.json has empty "oauth_client", add SHA-1 and redownload.',
      );
    }
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (!_firebaseAuthEnabled) return;
    await _googleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
