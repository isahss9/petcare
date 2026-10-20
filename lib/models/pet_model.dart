import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String name;
  final String species;
  final String breed;
  final DateTime birthDate;

  const PetModel({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDate,
  });

  factory PetModel.fromMap(Map<String, dynamic> map) {
    final rawBirthDate = map['birthDate'];

    final DateTime parsedBirthDate;

    if (rawBirthDate is Timestamp) {
      parsedBirthDate = rawBirthDate.toDate();
    } else if (rawBirthDate is DateTime) {
      parsedBirthDate = rawBirthDate;
    } else if (rawBirthDate is String) {
      parsedBirthDate = DateTime.parse(rawBirthDate);
    } else {
      throw const FormatException(
        'Data de nascimento inválida no registro do pet.',
      );
    }

    return PetModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      species: map['species'] as String? ?? '',
      breed: map['breed'] as String? ?? '',
      birthDate: parsedBirthDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birthDate': Timestamp.fromDate(birthDate),
    };
  }

  PetModel copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
