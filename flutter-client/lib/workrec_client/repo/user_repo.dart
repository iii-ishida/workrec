import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workrec_app/workrec_client/models/user.dart';

class UserRepo {
  final FirebaseFirestore _store;

  UserRepo({FirebaseFirestore? store})
      : _store = store ?? FirebaseFirestore.instance;

  Stream<User?> userStream(String id) {
    return _userDoc(_store, id).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      final data = doc.data() as Map<String, dynamic>;
      return User(
          id: doc.id,
          email: data['email'] as String,
          name: data['name'] as String,
          workingTaskId: data['workingTaskId'] as String);
    });
  }

  Future<void> putUser({
    required String id,
    required String email,
    String? name,
  }) async {
    final data = <String, dynamic>{
      'id': id,
      'email': email,
      'name': name ?? email,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _userDoc(_store, id).set(data);
  }

  DocumentReference _userDoc(FirebaseFirestore store, String userId) =>
      store.doc('users/$userId');
}
