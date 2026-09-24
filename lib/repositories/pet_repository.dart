import '../models/pet_model.dart';

abstract class PetRepository {
  Future<void> createPet(PetModel pet);

  Future<List<PetModel>> getPets();

  Future<void> updatePet(PetModel pet);

  Future<void> deletePet(String petId);
}
