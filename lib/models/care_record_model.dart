import 'package:cloud_firestore/cloud_firestore.dart';

enum CareType { vaccine, veterinaryAppointment, medication }

class CareRecordModel {
  final String id;
  final String petId;
  final String title;
  final CareType type;
  final String description;
  final DateTime date;

  const CareRecordModel({
    required this.id,
    required this.petId,
    required this.title,
    required this.type,
    required this.description,
    required this.date,
  });

  factory CareRecordModel.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final DateTime parsedDate;

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      throw const FormatException('Data do cuidado inválida.');
    }

    return CareRecordModel(
      id: map['id'] as String? ?? '',
      petId: map['petId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      type: CareType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => CareType.vaccine,
      ),
      description: map['description'] as String? ?? '',
      date: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'title': title,
      'type': type.name,
      'description': description,
      'date': Timestamp.fromDate(date),
    };
  }

  CareRecordModel copyWith({
    String? id,
    String? petId,
    String? title,
    CareType? type,
    String? description,
    DateTime? date,
  }) {
    return CareRecordModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
