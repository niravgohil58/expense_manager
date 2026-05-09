import 'dart:io';

import 'package:flutter/foundation.dart';

/// Firebase Auth + Firestore are enforced on Android/iOS only (offline-first desktop unchanged).
bool get firebaseAuthSupportedPlatform =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);
