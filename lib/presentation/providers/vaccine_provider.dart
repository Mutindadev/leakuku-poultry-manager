import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/data/models/vaccine_model.dart';
import 'package:leakuku/data/datasources/vaccine_local_data_source.dart';

/// Provider for vaccine data source
final vaccineDataSourceProvider = Provider<VaccineLocalDataSource>((ref) {
  final vaccineBox = Hive.box<List<dynamic>>('vaccineBox');
  return VaccineLocalDataSourceImpl(vaccineBox: vaccineBox);
});

/// Provider for vaccine schedule of a specific flock
final vaccineScheduleProvider = FutureProvider.family<List<VaccineModel>, String>((ref, flockId) async {
  final dataSource = ref.read(vaccineDataSourceProvider);
  return await dataSource.getVaccineScheduleForFlock(flockId);
});
