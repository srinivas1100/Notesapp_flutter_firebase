import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_notes_firebase/note.dart';
import 'package:flutter_notes_firebase/serveses/auth.dart';
import 'package:meta/meta.dart';

abstract class Database {
  Future<void> setNote(Notes notes);
  Stream<List<Notes>> notesStream();
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;
  
  @override
  Future<void> setNote(Notes notes) async => await setData(
        path: APIPath.notes(uid, documentIdFromCurrentDate()),
        data: notes.toMap(),
      );
  
  @override
  Stream<List<Notes>> notesStream() {
    final path = APIPath.note(uid);
    final reference = FirebaseFirestore.instance.collection(path).orderBy('id', descending: true);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => snapshot.docs
        .map(
          (snapshot) => Notes.fromMap(snapshot.data()),
        )
        .toList());
  }

  
  Future<void> setData({
    @required String path,
    @required Map<String, dynamic> data,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    print('$path: $data');
    await reference.set(data);
  }
}

