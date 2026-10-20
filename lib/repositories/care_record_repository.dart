import '../models/care_record_model.dart';

abstract class CareRecordRepository {
  Future<void> createRecord(CareRecordModel record);

  Future<List<CareRecordModel>> getRecords(String petId);

  Future<void> updateRecord(CareRecordModel record);

  Future<void> deleteRecord({required String petId, required String recordId});
}
