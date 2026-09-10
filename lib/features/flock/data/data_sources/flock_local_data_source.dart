import 'package:hive/hive.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';

abstract class FlockLocalDataSource {
  Future<List<FlockModel>> getAllFlocks(String userId);
  Future<FlockModel> getFlockById(String id);
  Future<void> addFlock(FlockModel flock);
  Future<void> updateFlock(FlockModel flock);
  Future<void> deleteFlock(String id);
}

class FlockLocalDataSourceImpl implements FlockLocalDataSource {
  final Box<FlockModel> flockBox;

  FlockLocalDataSourceImpl({required this.flockBox});

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
  }

  @override
  Future<void> updateFlock(FlockModel flock) async {
    await flockBox.put(flock.id, flock);
  }

  @override
  Future<void> deleteFlock(String id) async {
    await flockBox.delete(id);
  }
}
