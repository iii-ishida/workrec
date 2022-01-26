import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workrec_app/workrec_client/models/user.dart';

typedef _QueryDocument = DocumentSnapshot<Map<String, dynamic>>;

class UserRepo {
  final FirebaseFirestore _store;

  UserRepo({FirebaseFirestore? store})
      : _store = store ?? FirebaseFirestore.instance;

  Future<User> findUserById(String userId) {
    return _userDoc(_store, userId)
        .get()
        .then((doc) => _userFromDoc(doc as _QueryDocument));
  }

  Future<User> _userFromDoc(_QueryDocument doc) async {
    final data = doc.data()!;
    return User(id: doc.id, email: data['email'] as String, name: data['name'] as String);
  }

  Future<void> createUser(User user) {
    final data = <String, dynamic>{
      'email': user.email,
      'name': user.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    return _userDoc(_store, user.id).set(data);
  }

  Future<void> updateUser(User user) {
    final data = <String, dynamic>{
      'email': user.email,
      'name': user.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    return _userDoc(_store, user.id).update(data);
  }

  DocumentReference _userDoc(FirebaseFirestore store, String userId) =>
      store.doc('users/$userId');
}
