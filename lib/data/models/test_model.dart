import 'package:hive/hive.dart';

part 'test_model.g.dart';

@HiveType(typeId: 99)
class TestModel {
  @HiveField(0)
  String name;

  TestModel({required this.name});
}
