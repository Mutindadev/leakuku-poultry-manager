import 'package:leakuku/data/models/vaccine_model.dart';

/// Default broiler vaccination schedule (based on Kenya poultry standards)
/// Reference: Standard broiler vaccination protocol (Day 1 → Week 8)
final List<VaccineModel> defaultBroilerVaccines = [
  // Day 1: ND + IBD (Newcastle Disease + Infectious Bursal Disease)
  VaccineModel(
    id: 'broiler_day1_nd_ibd',
    dayOfCycle: 1,
    vaccineName: 'InnovaX ND/IBD',
    disease: 'Newcastle Disease + Infectious Bursal Disease',
    application: 'Eye drop or Drinking water',
    isOptional: false,
    breedId: 'broilers',
  ),

  // Day 7: Gumboro (IBD booster)
  VaccineModel(
    id: 'broiler_day7_gumboro',
    dayOfCycle: 7,
    vaccineName: 'Gumboro Vaccine (IBD)',
    disease: 'Infectious Bursal Disease',
    application: 'Drinking water',
    isOptional: false,
    breedId: 'broilers',
  ),

  // Day 14: ND Booster (Newcastle Disease)
  VaccineModel(
    id: 'broiler_day14_nd',
    dayOfCycle: 14,
    vaccineName: 'Newcastle Disease (LaSota)',
    disease: 'Newcastle Disease',
    application: 'Drinking water or Eye drop',
    isOptional: false,
    breedId: 'broilers',
  ),

  // Day 21: Gumboro Booster
  VaccineModel(
    id: 'broiler_day21_gumboro',
    dayOfCycle: 21,
    vaccineName: 'Gumboro Booster',
    disease: 'Infectious Bursal Disease',
    application: 'Drinking water',
    isOptional: false,
    breedId: 'broilers',
  ),

  // Week 6-8: Fowl Pox (optional for longer cycles)
  VaccineModel(
    id: 'broiler_week6_fowlpox',
    dayOfCycle: 42, // Week 6 start
    weekRange: 'Week 6-8',
    vaccineName: 'Fowl Pox Vaccine',
    disease: 'Fowl Pox',
    application: 'Wing web stab',
    isOptional: true,
    breedId: 'broilers',
  ),
];

/// Generate flock-specific vaccine schedule (offset by flock start date)
List<Map<String, dynamic>> generateFlockVaccineSchedule({
  required String flockId,
  required DateTime flockStartDate,
  required String breedId,
}) {
  final breedVaccines = defaultBroilerVaccines.where((v) => v.breedId == breedId).toList();
  
  return breedVaccines.map((vaccine) {
    final vaccineDate = flockStartDate.add(Duration(days: vaccine.scheduleDayOffset));
    return {
      'vaccine': vaccine,
      'vaccineDate': vaccineDate,
      'oneDayBefore': vaccineDate.subtract(const Duration(days: 1)),
      'flockId': flockId,
    };
  }).toList();
}
