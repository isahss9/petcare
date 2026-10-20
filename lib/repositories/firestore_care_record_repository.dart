import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/care_record_model.dart';
import 'care_record_repository.dart';

class FirestoreCareRecordRepository implements CareRecordRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreCareRecordRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _recordsCollection(String petId) {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'É necessário estar autenticado para acessar os cuidados.',
      );
    }

    if (petId.trim().isEmpty) {
      throw ArgumentError('O ID do pet é obrigatório.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(petId)
        .collection('careRecords');
  }

  @override
  Future<void> createRecord(CareRecordModel record) async {
    final collection = _recordsCollection(record.petId);
    final document = collection.doc();

    final recordToSave = record.copyWith(id: document.id);

    await document.set(recordToSave.toMap());
  }

  @override
  Future<List<CareRecordModel>> getRecords(String petId) async {
    final snapshot = await _recordsCollection(petId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((document) {
      return CareRecordModel.fromMap({
        ...document.data(),
        'id': document.id,
        'petId': petId,
      });
    }).toList();
  }

  @override
  Future<void> updateRecord(CareRecordModel record) async {
    if (record.id.trim().isEmpty) {
      throw ArgumentError('O ID do registro é obrigatório para atualizar.');
    }

    await _recordsCollection(record.petId)
        .doc(record.id)
        .update(record.toMap());
  }

  @override
  Future<void> deleteRecord({
    required String petId,
    required String recordId,
  }) async {
    if (recordId.trim().isEmpty) {
      throw ArgumentError('O ID do registro é obrigatório.');
    }

    await _recordsCollection(petId).doc(recordId).delete();
  }
}
