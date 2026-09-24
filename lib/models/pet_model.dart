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

  /// Cria um PetModel a partir de um mapa de dados.
  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      species: map['species'] as String? ?? '',
      breed: map['breed'] as String? ?? '',
      birthDate: DateTime.parse(map['birthDate'] as String),
    );
  }

  /// Converte o PetModel em um mapa.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birthDate': birthDate.toIso8601String(),
    };
  }

  /// Cria uma cópia do pet alterando apenas os campos necessários.
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
