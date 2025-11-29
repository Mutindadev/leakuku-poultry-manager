import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/data/models/breed_model.dart';
import 'package:leakuku/data/datasources/breed_local_data_source.dart';
import 'package:leakuku/domain/usecases/get_breeds.dart';

/// Provider for breed data source
final breedDataSourceProvider = Provider<BreedLocalDataSource>((ref) {
  final breedBox = Hive.box<BreedModel>('breedBox');
  return BreedLocalDataSourceImpl(breedBox: breedBox);
});

/// Provider for GetBreeds use case
final getBreedsUseCaseProvider = Provider<GetBreedsUseCase>((ref) {
  final dataSource = ref.read(breedDataSourceProvider);
  return GetBreedsUseCase(breedDataSource: dataSource);
});

/// State provider for breed list
final breedListProvider = FutureProvider<List<BreedModel>>((ref) async {
  final useCase = ref.read(getBreedsUseCaseProvider);
  return await useCase.execute();
});
