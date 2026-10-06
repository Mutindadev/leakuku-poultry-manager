import 'package:hive/hive.dart';
import 'package:leakuku/core/services/firestore_collection_data_source.dart';
import 'package:leakuku/core/services/firestore_sync_queue.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';

abstract class FlockLocalDataSource {
  Future<List<FlockModel>> getAllFlocks(String userId);
  Future<FlockModel> getFlockById(String id);
  Future<void> addFlock(FlockModel flock);
  Future<void> updateFlock(FlockModel flock);
  Future<void> deleteFlock(String id);
}

class FlockLocalDataSourceImpl implements FlockLocalDataSource {
  final Box<FlockModel> flockBox;
  final FirestoreSyncQueue? syncQueue;

  FlockLocalDataSourceImpl({required this.flockBox, this.syncQueue});

  @override
  Future<List<FlockModel>> getAllFlocks(String userId) async {
    return flockBox.values.where((flock) => flock.userId == userId).toList();
  }

  @override
  Future<FlockModel> getFlockById(String id) async {
    final flock = flockBox.get(id);
    if (flock == null) {
      throw Exception('Flock not found');
    }
    return flock;
  }

  @override
  Future<void> addFlock(FlockModel flock) async {
    await flockBox.put(flock.id, flock);
    await syncQueue?.upsert(
      uid: flock.userId,
      collection: FirestoreCollections.flocks,
      id: flock.id,
      data: flock.toMap(),
    );
  }

  @override
  Future<void> updateFlock(FlockModel flock) async {
    await flockBox.put(flock.id, flock);
    await syncQueue?.upsert(
      uid: flock.userId,
      collection: FirestoreCollections.flocks,
      id: flock.id,
      data: flock.toMap(),
    );
  }

  @override
  Future<void> deleteFlock(String id) async {
    final flock = flockBox.get(id);
    await flockBox.delete(id);
    if (flock != null) {
      await syncQueue?.delete(
        uid: flock.userId,
        collection: FirestoreCollections.flocks,
        id: id,
      );
    }
  }
}
