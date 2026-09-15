import 'package:equatable/equatable.dart';

class Flock extends Equatable {
  final String id;
  final String farmerId;
  final String location;
  final String chickenType;
  final DateTime startDate;
  final int batchSize;

  const Flock({
    required this.id,
    required this.farmerId,
    required this.location,
    required this.chickenType,
    required this.startDate,
    required this.batchSize,
  });

  @override
  List<Object> get props => [id, farmerId, location, chickenType, startDate, batchSize];
}
