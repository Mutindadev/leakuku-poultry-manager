import 'package:hive/hive.dart';
import 'package:leakuku/data/models/breed_model.dart';

/// Local data source for breed profiles (Hive-backed)
abstract class BreedLocalDataSource {
  /// Get all available breeds
  Future<List<BreedModel>> getAllBreeds();
  
  /// Get a specific breed by ID
  Future<BreedModel?> getBreedById(String id);
  
  /// Seed default breeds if box is empty (run once on first launch)
  Future<void> seedDefaultBreeds();
  
  /// Add or update a breed (for future admin features)
  Future<void> saveBreed(BreedModel breed);
}

class BreedLocalDataSourceImpl implements BreedLocalDataSource {
  final Box<BreedModel> _breedBox;

  BreedLocalDataSourceImpl({required Box<BreedModel> breedBox}) : _breedBox = breedBox;

  @override
  Future<List<BreedModel>> getAllBreeds() async {
    // Defensive: check if box is open
    if (!Hive.isBoxOpen('breedBox')) {
      throw Exception('Breed box not initialized');
    }
    return _breedBox.values.toList();
  }

  @override
  Future<BreedModel?> getBreedById(String id) async {
    if (!Hive.isBoxOpen('breedBox')) {
      throw Exception('Breed box not initialized');
    }
    return _breedBox.get(id);
  }

  @override
  Future<void> saveBreed(BreedModel breed) async {
    if (!Hive.isBoxOpen('breedBox')) {
      throw Exception('Breed box not initialized');
    }
    await _breedBox.put(breed.id, breed);
  }

  @override
  Future<void> seedDefaultBreeds() async {
    // Only seed if box is empty
    if (_breedBox.isNotEmpty) {
      return; // Already seeded
    }

    // Default breed profiles based on Kenya poultry standards
    final defaultBreeds = [
      _createBroilerBreed(),
      _createLayerBreed(),
      _createKenbroBreed(),
    ];

    for (final breed in defaultBreeds) {
      await _breedBox.put(breed.id, breed);
    }
  }

  /// Broilers: 35-day cycle, meat production
  BreedModel _createBroilerBreed() {
    return BreedModel(
      id: 'broilers',
      name: 'Broilers',
      purpose: 'Meat production (fast-growing)',
      keyBenefits: [
        'Fast growth (35 days to maturity)',
        'High feed conversion ratio',
        'Quick ROI',
        'Consistent market demand',
      ],
      weeklyExpectedWeight: {
        1: 0.15, // 150g
        2: 0.35, // 350g
        3: 0.65, // 650g
        4: 1.20, // 1.2kg
        5: 1.80, // 1.8kg (market weight)
      },
      weeklyFeedGrams: {
        1: 140,   // 20g/day
        2: 280,   // 40g/day
        3: 560,   // 80g/day
        4: 840,   // 120g/day
        5: 1120,  // 160g/day
      },
      expectedEggsPerYear: null, // Not applicable for broilers
      cycleDurationDays: 35,
      defaultFeedGramsPerWeek: 560, // Avg ~80g/day
    );
  }

  /// Layers: 150-day cycle, egg production
  BreedModel _createLayerBreed() {
    return BreedModel(
      id: 'layers',
      name: 'Layers',
      purpose: 'Egg production (high-laying hens)',
      keyBenefits: [
        'High egg production (280+ eggs/year)',
        'Consistent income stream',
        'Lower feed cost per egg',
        'Long productive life (18-24 months)',
      ],
      weeklyExpectedWeight: {
        1: 0.08,  // 80g
        4: 0.30,  // 300g
        8: 0.65,  // 650g
        12: 1.00, // 1kg
        16: 1.35, // 1.35kg
        20: 1.55, // 1.55kg (maturity ~5 months)
      },
      weeklyFeedGrams: {
        1: 140,   // 20g/day
        4: 245,   // 35g/day
        8: 350,   // 50g/day
        12: 490,  // 70g/day
        16: 630,  // 90g/day
        20: 735,  // 105g/day (laying phase)
      },
      expectedEggsPerYear: 280,
      cycleDurationDays: 150, // ~5 months to start laying
      defaultFeedGramsPerWeek: 735, // Laying phase
    );
  }

  /// Improved Kienyeji (Kenbro): 90-day cycle, dual purpose
  BreedModel _createKenbroBreed() {
    return BreedModel(
      id: 'kenbro',
      name: 'Improved Kienyeji (Kenbro)',
      purpose: 'Dual purpose (meat + eggs)',
      keyBenefits: [
        'Hardy and disease-resistant',
        'Good meat quality',
        'Moderate egg production (180-200 eggs/year)',
        'Lower feed requirements',
      ],
      weeklyExpectedWeight: {
        1: 0.08,  // 80g
        4: 0.25,  // 250g
        8: 0.60,  // 600g
        12: 1.20, // 1.2kg
        13: 1.40, // 1.4kg (90 days ~13 weeks)
      },
      weeklyFeedGrams: {
        1: 140,  // 20g/day
        4: 210,  // 30g/day
        8: 280,  // 40g/day
        12: 385, // 55g/day
        13: 420, // 60g/day
      },
      expectedEggsPerYear: 190,
      cycleDurationDays: 90, // ~3 months
      defaultFeedGramsPerWeek: 420, // Mature phase
    );
  }
}
