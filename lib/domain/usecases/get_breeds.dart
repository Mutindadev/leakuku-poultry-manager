import 'package:leakuku/data/models/breed_model.dart';
import 'package:leakuku/data/datasources/breed_local_data_source.dart';

/// Use case: Fetch all available breed profiles
class GetBreedsUseCase {
  final BreedLocalDataSource breedDataSource;

  GetBreedsUseCase({required this.breedDataSource});

  Future<List<BreedModel>> execute() async {
    return await breedDataSource.getAllBreeds();
  }
}
