// ignore_for_file: public_member_api_docs, sort_constructors_first

class DailyRecords {
  DateTime date;
  DateTime createdAt;
  DateTime updatedAt;
  List<dynamic> checklist;
  List<dynamic> completedTask;
  String mortalityCount;

  DailyRecords({
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.checklist,
    required this.completedTask,
    required this.mortalityCount,
  });
}
