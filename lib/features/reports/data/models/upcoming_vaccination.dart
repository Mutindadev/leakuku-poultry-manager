class UpcomingVaccination {
  final String flockName;
  final String vaccineName;
  final DateTime dueDate;

  const UpcomingVaccination({
    required this.flockName,
    required this.vaccineName,
    required this.dueDate,
  });

  String get dueLabel {
    final remainingDays = this.remainingDays;
    if (remainingDays <= 0) {
      return 'Due today';
    }
    if (remainingDays == 1) {
      return 'Due tomorrow';
    }
    return 'Due in $remainingDays days';
  }

  int get remainingDays => dueDate.difference(DateTime.now()).inDays;
}
