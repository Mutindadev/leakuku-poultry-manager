import 'package:leakuku/data/models/vaccine_model.dart';

class VaccineStatus {
  final VaccineModel vaccine;
  final DateTime dueDate;

  const VaccineStatus({required this.vaccine, required this.dueDate});
}
