import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFireStoreDBHelper {
  CloudFireStoreDBHelper._();
  static final CloudFireStoreDBHelper cloudFireStoreDBHelper =
  CloudFireStoreDBHelper._();

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late CollectionReference notes;

  void connectWithNoteKeeperCollection() {
    notes = firebaseFirestore.collection('notes');
  }

  Future<void> insertRecord({
    required String id,
    required String title,
    required String note,
    required String time,
  }) async {
    connectWithNoteKeeperCollection();

    Map<String, dynamic> data = {
      'title': title,
      'note': note,
      'time': time,
    };

    await notes.doc(id).set(data);
  }

  Stream<QuerySnapshot> selectRecord() {
    connectWithNoteKeeperCollection();

    return notes.snapshots();
  }

  Future<void> updateRecord(
      {required String id,
      required String title,
      required String note,}) async {
    connectWithNoteKeeperCollection();

    Map<String, dynamic> updatedData = {
      'title': title,
      'note': note,
    };

    await notes.doc(id).update(updatedData);
  }

  Future<void> deleteRecord({required String id}) async {
    connectWithNoteKeeperCollection();

    await notes.doc(id).delete();
  }
}
