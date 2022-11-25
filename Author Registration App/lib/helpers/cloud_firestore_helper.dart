import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFireStoreDBHelper {
  CloudFireStoreDBHelper._();
  static final CloudFireStoreDBHelper cloudFireStoreDBHelper =
  CloudFireStoreDBHelper._();

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late CollectionReference notes;

  void connectWithNoteKeeperCollection() {
    notes = firebaseFirestore.collection('Books');
  }

  Future<void> insertRecord({
    required Map<String, dynamic> data
  }) async {
    connectWithNoteKeeperCollection();

    await notes.doc().set(data);
  }

  Stream<QuerySnapshot> selectRecord() {
    connectWithNoteKeeperCollection();

    return notes.snapshots();
  }

  Future<void> updateRecord(
      {required String id, required Map<String, dynamic> data}) async {
    connectWithNoteKeeperCollection();

    await notes.doc(id).update(data);
  }

  Future<void> deleteRecord({required String id}) async {
    connectWithNoteKeeperCollection();

    await notes.doc(id).delete();
  }
}
