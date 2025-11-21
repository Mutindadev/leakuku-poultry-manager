import 'package:equatable/equatable.dart';

class Flock extends Equatable {
  final String id;
  final String name;
  final String breed;
  final int quantity;
  final DateTime purchaseDate;
  final String? notes;
  final String userId;

  const Flock({
    required this.id,
    required this.name,
    required this.breed,
    required this.quantity,
    required this.purchaseDate,
    this.notes,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, name, breed, quantity, purchaseDate, notes, userId];
}
