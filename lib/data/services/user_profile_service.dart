import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Remote user profile in Firestore `users/{uid}` — merge-safe for future backends.
class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  FirebaseFirestore get _db => _override ?? FirebaseFirestore.instance;

  Future<void> syncRemoteProfile(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final snap = await doc.get();
    final payload = <String, dynamic>{
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!snap.exists) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }
    await doc.set(payload, SetOptions(merge: true));
  }
}
