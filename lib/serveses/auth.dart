import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserId {
  UserId({@required this.email, @required this.name, @required this.uid});
  final String uid;
  final String email;
  final String name;

   Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }

   factory UserId.fromMap(Map<String, dynamic> data) {
   final String name = data['name'];
    final String email = data['email'];
    final String uid = data['uid'];
    return UserId( name: name, email: email, uid: uid);
  }
}

abstract class AuthBase {

  User get currentUser;

  Future<void> userData(UserId userId);

  Stream<UserId> userStream();
  
  Stream<UserId> authStateChanged();
  
  Future<UserId> signInWithEmailAndPassword(String email,String password);
  
  Future<UserId> createUserWithEmailAndPassword(String email,String password);
  
  Future<void> signOut();
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  UserId _userFromFirebase(User user) {
    if (user == null) {
      return null;
    }
    return UserId(uid: user.uid, email: user.email, name: user.displayName);
  } 
  
  @override
  Future<void> userData(UserId userId) async => await idData(
    path: APIPath.userdata(uid: _firebaseAuth.currentUser.uid),
    data: userId.toMap(),
  );

   Future<void> idData({
    @required String path,
    @required Map<String, dynamic> data,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    print('$path: $data');
    await reference.set(data);
  }

  @override
  Stream<UserId> userStream() {
    final path = APIPath.userdata(uid: _firebaseAuth.currentUser.uid);
    final reference = FirebaseFirestore.instance.doc(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => UserId.fromMap(snapshot.data()));
  }
  
  
  @override
  Stream<UserId> authStateChanged() => _firebaseAuth.authStateChanges().map(_userFromFirebase);
  
  @override
  User get currentUser => _firebaseAuth.currentUser;
  
  @override
  Future<UserId> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
    return _userFromFirebase(userCredential.user);
  } 

  @override
  Future<UserId> createUserWithEmailAndPassword(String email,String password) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return _userFromFirebase(userCredential.user);
  } 

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

class APIPath {
  static String userdata({String uid}) => 'users/$uid';
  static String notes(String uid, String txnId) => 'users/$uid/notes/$txnId';
  static String note(String uid) => 'users/$uid/notes';


}