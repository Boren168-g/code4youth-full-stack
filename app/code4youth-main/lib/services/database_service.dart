import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code4youth/models/user.dart';

class DatabaseService {
  FirebaseFirestore? _db;

  DatabaseService() {
    try {
      _db = FirebaseFirestore.instance;
    } catch (e) {
      print('Firestore not initialized yet');
    }
  }

  Future<void> saveProfile(String uid, UserProfile profile) async {
    if (_db == null) return;
    await _db!.collection('users').doc(uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getProfile(String uid) async {
    if (_db == null) return null;
    final doc = await _db!.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> saveProgress(String uid, Map<String, dynamic> progress) async {
    if (_db == null) return;
    await _db!.collection('users').doc(uid).collection('progress').doc('data').set(progress, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProgress(String uid) async {
    if (_db == null) return null;
    final doc = await _db!.collection('users').doc(uid).collection('progress').doc('data').get();
    return doc.data();
  }
}
