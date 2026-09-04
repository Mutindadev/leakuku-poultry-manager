import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/progress/data/models/daily_task.dart';

class ProgressService {
  const ProgressService();

  WeeklyPlanModel? findCurrentPlan(
    List<WeeklyPlanModel> plans,
    int currentWeek,
  ) {
    for (final plan in plans) {
      if (plan.weekNumber == currentWeek) {
        return plan;
      }
    }

    return null;
  }

  int dueVaccinesToday(
    DateTime purchaseDate,
    List<dynamic> vaccines, {
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();

    return vaccines.where((vaccine) {
      final dueDate = purchaseDate.add(
        Duration(days: vaccine.scheduleDayOffset),
      );

      return isSameDate(dueDate, currentDate);
    }).length;
  }

  bool isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String getStage(int ageDays) {
    if (ageDays <= 21) {
      return 'Brooding';
    }

    if (ageDays <= 140) {
      return 'Growing';
    }

    return 'Production';
  }

  int estimateMortalityCount(
    int currentBirdsAlive,
    double mortalityPercent,
  ) {
    final base = currentBirdsAlive == 0 ? 1 : currentBirdsAlive;
    return ((mortalityPercent / 100) * base).round();
  }

  List<DailyTask> buildTasks({
    required String stage,
    required WeeklyPlanModel? currentPlan,
    required int dueVaccinesToday,
  }) {
    final tasks = <DailyTask>[
      DailyTask(
        title: 'Feed birds',
        subtitle: currentPlan == null
            ? null
            : 'Target feed is ${currentPlan.plannedTotalFeedKg.toStringAsFixed(1)} kg today.',
        icon: FontAwesomeIcons.wheatAwn,
        color: AppColors.leakukuGreen,
      ),
      const DailyTask(
        title: 'Refresh water',
        subtitle: 'Clean drinkers and refill fresh water.',
        icon: FontAwesomeIcons.glassWater,
        color: Colors.blue,
      ),
      const DailyTask(
        title: 'Observe bird activity',
        subtitle: 'Watch appetite, movement, and comfort in the house.',
        icon: FontAwesomeIcons.eye,
        color: Colors.teal,
      ),
      const DailyTask(
        title: 'Check litter',
        subtitle: 'Remove wet spots and keep the floor dry.',
        icon: FontAwesomeIcons.broom,
        color: Colors.brown,
      ),
      const DailyTask(
        title: 'Record mortality',
        subtitle: 'Confirm any birds lost before you finish the day.',
        icon: FontAwesomeIcons.heartPulse,
        color: Colors.red,
      ),
      DailyTask(
        title: stage == 'Brooding'
            ? 'Check brooder temperature'
            : 'Weigh sample birds',
        subtitle: stage == 'Brooding'
            ? 'Make sure chicks stay warm and evenly spread.'
            : 'Compare sample weight with the expected growth.',
        icon: stage == 'Brooding'
            ? FontAwesomeIcons.temperatureHalf
            : FontAwesomeIcons.weightScale,
        color: stage == 'Brooding' ? Colors.deepOrange : Colors.indigo,
      ),
    ];

    if (dueVaccinesToday > 0) {
      tasks.add(
        DailyTask(
          title: 'Administer scheduled vaccine',
          subtitle: dueVaccinesToday == 1
              ? 'There is 1 vaccine due today.'
              : 'There are $dueVaccinesToday vaccines due today.',
          icon: FontAwesomeIcons.syringe,
          color: Colors.purple,
        ),
      );
    }

    return tasks;
  }

  String buildDailyNote({
    required DateTime date,
    required String healthStatus,
    required String healthNotes,
    required int? waterRefills,
    required String mortalityNotes,
    required String generalNotes,
    required int completedTasks,
    required int totalTasks,
    required List<String> completedTaskTitles,
  }) {
    final parts = <String>[
      'Health: $healthStatus',
      'Checklist: $completedTasks/$totalTasks',
    ];

    if (waterRefills != null) {
      parts.add('Water refills: $waterRefills');
    }

    if (completedTaskTitles.isNotEmpty) {
      parts.add('Completed: ${completedTaskTitles.join(', ')}');
    }

    if (healthNotes.isNotEmpty) {
      parts.add('Health notes: $healthNotes');
    }

    if (mortalityNotes.isNotEmpty) {
      parts.add('Mortality notes: $mortalityNotes');
    }

    if (generalNotes.isNotEmpty) {
      parts.add('General notes: $generalNotes');
    }

    return '[Daily Record ${dateKey(date)}] ${parts.join(' | ')}';
  }

  String? mergeDailyRecordNote(
    String? existingNotes,
    String dailyNote,
  ) {
    final lines = (existingNotes ?? '')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    final notePrefix = dailyNote.split(']').first;

    lines.removeWhere((line) => line.startsWith(notePrefix));
    lines.add(dailyNote);

    return lines.isEmpty ? null : lines.join('\n');
  }

  DailyRecordDraft extractDailyRecordDraft(
    String? notes,
    DateTime date,
  ) {
    final key = '[Daily Record ${dateKey(date)}]';
    final lines = (notes ?? '').split('\n');

    String? matchingLine;

    for (final line in lines) {
      if (line.startsWith(key)) {
        matchingLine = line;
        break;
      }
    }

    if (matchingLine == null) {
      return const DailyRecordDraft();
    }

    String? readValue(String prefix) {
      for (final section in matchingLine!.split(' | ')) {
        if (section.startsWith(prefix)) {
          return section.substring(prefix.length).trim();
        }
      }

      return null;
    }

    return DailyRecordDraft(
      healthStatus: readValue('Health: '),
      waterRefills: readValue('Water refills: '),
      healthNotes: readValue('Health notes: '),
      mortalityNotes: readValue('Mortality notes: '),
      generalNotes: readValue('General notes: '),
    );
  }

  String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String formatAgeLabel(int ageDays) {
    if (ageDays <= 0) {
      return 'Day 0';
    }
    return 'Day $ageDays';
  }

  String formatWholeNumber(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      final remaining = digits.length - index;
      buffer.write(digits[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}

class DailyRecordDraft {
  final String? healthStatus;
  final String? waterRefills;
  final String? healthNotes;
  final String? mortalityNotes;
  final String? generalNotes;

  const DailyRecordDraft({
    this.healthStatus,
    this.waterRefills,
    this.healthNotes,
    this.mortalityNotes,
    this.generalNotes,
  });
}
