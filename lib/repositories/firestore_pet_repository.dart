import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/pet_model.dart';
import 'pet_repository.dart';

class FirestorePetRepository implements PetRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestorePetRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _petsCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('É necessário estar autenticado para acessar os pets.');
    }

    return _firestore.collection('users').doc(user.uid).collection('pets');
  }

  @override
  Future<void> createPet(PetModel pet) async {
    final document = _petsCollection.doc();

    final petToSave = pet.copyWith(id: document.id);

    await document.set(petToSave.toMap());
  }

  @override
  Future<List<PetModel>> getPets() async {
    final snapshot = await _petsCollection.orderBy('name').get();

    return snapshot.docs.map((document) {
      return PetModel.fromMap({...document.data(), 'id': document.id});
    }).toList();
  }

  @override
  Future<void> updatePet(PetModel pet) async {
    if (pet.id.isEmpty) {
      throw ArgumentError(
        'O ID do pet é obrigatório para atualizar o registro.',
      );
    }

    await _petsCollection.doc(pet.id).update(pet.toMap());
  }

  @override
  Future<void> deletePet(String petId) async {
    if (petId.isEmpty) {
      throw ArgumentError('O ID do pet não pode estar vazio.');
    }

    await _petsCollection.doc(petId).delete();
  }
}
