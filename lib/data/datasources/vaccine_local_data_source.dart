import 'package:hive/hive.dart';
import 'package:leakuku/core/services/firestore_collection_data_source.dart';
import 'package:leakuku/core/services/firestore_sync_queue.dart';
import 'package:leakuku/data/models/vaccine_model.dart';

/// Local data source for vaccine schedules (Hive-backed)
abstract class VaccineLocalDataSource {
  /// Get vaccine schedule for a specific flock
  Future<List<VaccineModel>> getVaccineScheduleForFlock(String flockId);

  /// Save vaccine schedule for a flock (auto-generated on flock creation)
  Future<void> saveVaccineSchedule(
    String userId,
    String flockId,
    List<VaccineModel> vaccines,
  );

  /// Mark a vaccine as completed
  Future<void> markVaccineCompleted(
    String userId,
    String flockId,
    String vaccineId,
    DateTime completedDate,
  );

  /// Get all vaccine templates for a specific breed (for generation)
  Future<List<VaccineModel>> getVaccineTemplatesByBreed(String breedId);

  /// Delete all vaccines for a flock (when flock deleted)
  Future<void> deleteVaccineSchedule(String userId, String flockId);
}

class VaccineLocalDataSourceImpl implements VaccineLocalDataSource {
  final Box<List<dynamic>> _vaccineBox; // Store List<VaccineModel> per flockId
  final FirestoreSyncQueue? syncQueue;

  VaccineLocalDataSourceImpl({
    required Box<List<dynamic>> vaccineBox,
    this.syncQueue,
  }) : _vaccineBox = vaccineBox;

  @override
  Future<List<VaccineModel>> getVaccineScheduleForFlock(String flockId) async {
    // Defensive: check box open
    if (!Hive.isBoxOpen('vaccineBox')) {
      throw Exception('Vaccine box not initialized');
    }

    final rawList = _vaccineBox.get(flockId);
    if (rawList == null) return [];

    // Cast to VaccineModel list
    return rawList.whereType<VaccineModel>().toList();
  }

  @override
  Future<void> saveVaccineSchedule(
    String userId,
    String flockId,
    List<VaccineModel> vaccines,
  ) async {
    if (!Hive.isBoxOpen('vaccineBox')) {
      throw Exception('Vaccine box not initialized');
    }

    final previous = await getVaccineScheduleForFlock(flockId);
    final now = DateTime.now();
    final savedVaccines = vaccines
        .map((vaccine) => vaccine.copyWith(
              id: '${flockId}_${vaccine.id}',
              flockId: flockId,
              createdAt: vaccine.createdAt ?? now,
              updatedAt: now,
            ))
        .toList();
    await _vaccineBox.put(flockId, savedVaccines);
    final savedIds = savedVaccines.map((vaccine) => vaccine.id).toSet();
    for (final vaccine
        in previous.where((item) => !savedIds.contains(item.id))) {
      await syncQueue?.delete(
        uid: userId,
        collection: FirestoreCollections.vaccines,
        id: vaccine.id,
        parentCollection: FirestoreCollections.flocks,
        parentId: flockId,
      );
    }
    for (final vaccine in savedVaccines) {
      await syncQueue?.upsert(
        uid: userId,
        collection: FirestoreCollections.vaccines,
        id: vaccine.id,
        data: vaccine.toMap(),
        parentCollection: FirestoreCollections.flocks,
        parentId: flockId,
      );
    }
  }

  @override
  Future<void> markVaccineCompleted(
    String userId,
    String flockId,
    String vaccineId,
    DateTime completedDate,
  ) async {
    final vaccines = await getVaccineScheduleForFlock(flockId);
    final index = vaccines.indexWhere((vaccine) => vaccine.id == vaccineId);
    if (index < 0) throw StateError('Vaccine schedule entry not found.');

    final updated = vaccines[index].copyWith(
      status: 'done',
      completedAt: completedDate,
      updatedAt: DateTime.now(),
    );
    vaccines[index] = updated;
    await _vaccineBox.put(flockId, vaccines);
    await syncQueue?.upsert(
      uid: userId,
      collection: FirestoreCollections.vaccines,
      id: updated.id,
      data: updated.toMap(),
      parentCollection: FirestoreCollections.flocks,
      parentId: flockId,
    );
  }

  @override
  Future<List<VaccineModel>> getVaccineTemplatesByBreed(String breedId) async {
    // Return default vaccine templates based on breed
    // Currently hardcoded; in future, could be stored in Hive or fetched from API
    return _getDefaultVaccineTemplates(breedId);
  }

  @override
  Future<void> deleteVaccineSchedule(String userId, String flockId) async {
    if (!Hive.isBoxOpen('vaccineBox')) {
      throw Exception('Vaccine box not initialized');
    }

    final vaccines = await getVaccineScheduleForFlock(flockId);
    await _vaccineBox.delete(flockId);
    for (final vaccine in vaccines) {
      await syncQueue?.delete(
        uid: userId,
        collection: FirestoreCollections.vaccines,
        id: vaccine.id,
        parentCollection: FirestoreCollections.flocks,
        parentId: flockId,
      );
    }
  }

  /// Default vaccine templates (hardcoded for now, matches default_vaccines.dart)
  List<VaccineModel> _getDefaultVaccineTemplates(String breedId) {
    // For now, only broilers have a defined schedule
    // TODO: Add schedules for layers and kenbro in future
    if (breedId == 'broilers') {
      return [
        VaccineModel(
          id: 'broiler_day1_nd_ibd',
          dayOfCycle: 1,
          vaccineName: 'InnovaX ND/IBD',
          disease: 'Newcastle Disease + Infectious Bursal Disease',
          application: 'Eye drop or Drinking water',
          isOptional: false,
          breedId: 'broilers',
        ),
        VaccineModel(
          id: 'broiler_day7_gumboro',
          dayOfCycle: 7,
          vaccineName: 'Gumboro Vaccine (IBD)',
          disease: 'Infectious Bursal Disease',
          application: 'Drinking water',
          isOptional: false,
          breedId: 'broilers',
        ),
        VaccineModel(
          id: 'broiler_day14_nd',
          dayOfCycle: 14,
          vaccineName: 'Newcastle Disease (LaSota)',
          disease: 'Newcastle Disease',
          application: 'Drinking water or Eye drop',
          isOptional: false,
          breedId: 'broilers',
        ),
        VaccineModel(
          id: 'broiler_day21_gumboro',
          dayOfCycle: 21,
          vaccineName: 'Gumboro Booster',
          disease: 'Infectious Bursal Disease',
          application: 'Drinking water',
          isOptional: false,
          breedId: 'broilers',
        ),
        VaccineModel(
          id: 'broiler_week6_fowlpox',
          dayOfCycle: 42,
          weekRange: 'Week 6-8',
          vaccineName: 'Fowl Pox Vaccine',
          disease: 'Fowl Pox',
          application: 'Wing web stab',
          isOptional: true,
          breedId: 'broilers',
        ),
      ];
    }

    // Return empty for other breeds (to be implemented)
    return [];
  }
}
