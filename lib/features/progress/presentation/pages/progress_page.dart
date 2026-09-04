import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/progress/data/models/daily_task.dart';
import 'package:leakuku/features/progress/domain/service/progress_service.dart';
import 'package:leakuku/features/progress/presentation/widgets/empty_daily_record.dart';
import 'package:leakuku/features/progress/presentation/widgets/header_card.dart';
import 'package:leakuku/features/progress/presentation/widgets/plan_card.dart';
import 'package:leakuku/features/progress/presentation/widgets/record_card.dart';
import 'package:leakuku/presentation/providers/vaccine_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

class ProgressPage extends ConsumerStatefulWidget {
  final bool showAppBar;

  const ProgressPage({super.key, this.showAppBar = false});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> {
  final _progressService = const ProgressService();

  final _feedController = TextEditingController();
  final _waterRefillsController = TextEditingController();
  final _healthNotesController = TextEditingController();
  final _mortalityController = TextEditingController();
  final _mortalityNotesController = TextEditingController();
  final _weightController = TextEditingController();
  final _generalNotesController = TextEditingController();

  final Map<String, Map<String, bool>> _taskStateByFlock = {};
  String _healthStatus = 'Healthy';
  String? _loadedDraftKey;
  bool _isSaving = false;

  late FlockModel _currentFlock;
  WeeklyPlanModel? _currentPlan;
  int _currentWeek = 1;
  int _completedTasks = 0;
  int _totalTasks = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (ref.read(flockProvider).flocks.isEmpty) {
        ref.read(flockProvider.notifier).loadFlocks();
      }
    });
  }

  @override
  void dispose() {
    _feedController.dispose();
    _waterRefillsController.dispose();
    _healthNotesController.dispose();
    _mortalityController.dispose();
    _mortalityNotesController.dispose();
    _weightController.dispose();
    _generalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flockState = ref.watch(flockProvider);
    final flocks = flockState.flocks;
    final selectedFlock = ref.watch(selectedFlockProvider);

    final flock = selectedFlock ?? flocks.first;
    final ageDays = DateTime.now().difference(flock.purchaseDate).inDays;
    final stage = _progressService.getStage(ageDays);
    final currentWeek = ageDays < 0 ? 1 : (ageDays ~/ 7) + 1;
    final weeklyPlansAsync = ref.watch(weeklyPlansProvider(flock.id));
    final vaccineScheduleAsync = ref.watch(vaccineScheduleProvider(flock.id));

    final plans = weeklyPlansAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <WeeklyPlanModel>[],
    );
    final currentPlan = _progressService.findCurrentPlan(plans, currentWeek);
    final vaccines = vaccineScheduleAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const [],
    );
    final tasks = _progressService.buildTasks(
      stage: stage,
      currentPlan: currentPlan,
      dueVaccinesToday:
          _progressService.dueVaccinesToday(flock.purchaseDate, vaccines),
    );

    _syncDraftState(
      flock: flock,
      currentPlan: currentPlan,
      tasks: tasks,
      currentWeek: currentWeek,
    );

    final taskState = _taskStateByFlock[flock.id] ?? const <String, bool>{};
    final completedTasks = taskState.values.where((value) => value).length;

    _currentFlock = flock;
    _currentPlan = currentPlan;
    _currentWeek = currentWeek;
    _completedTasks = completedTasks;
    _totalTasks = tasks.length;

    final body = Container(
      color: AppColors.farmCream,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                HeaderCard(
                  flock: flock,
                  ageDays: ageDays,
                  stage: stage,
                  completedTasks: completedTasks,
                  totalTasks: tasks.length,
                  allFlocks: flocks,
                ),
                const SizedBox(height: 16),
                PlanCard(
                  flockId: flock.id,
                  tasks: tasks,
                  taskState: taskState,
                  onTaskStateChanged: (updatedTaskState) {
                    setState(() {
                      _taskStateByFlock[flock.id] = updatedTaskState;
                    });
                  },
                ),
                const SizedBox(height: 16),
                RecordCard(
                  flock: flock,
                  currentPlan: currentPlan,
                  ageDays: ageDays,
                  weeklyPlansLoading: weeklyPlansAsync.isLoading,
                  feedController: _feedController,
                  waterRefillsController: _waterRefillsController,
                  healthNotesController: _healthNotesController,
                  mortalityController: _mortalityController,
                  mortalityNotesController: _mortalityNotesController,
                  weightController: _weightController,
                  generalNotesController: _generalNotesController,
                  healthStatus: _healthStatus,
                  onHealthStatusChanged: (status) {
                    setState(() {
                      _healthStatus = status;
                      if (_healthStatus != 'Needs attention') {
                        _healthNotesController.clear();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.farmCream,
      appBar:
          widget.showAppBar ? AppBar(title: const Text('Daily Records')) : null,
      body: Builder(
        builder: (context) {
          if (flockState.isLoading && flocks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (flocks.isEmpty) {
            return EmptyDailyRecordsState(showAppBar: widget.showAppBar);
          } else {
            return body;
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving
            ? null
            : () => _saveRecord(
                  flock: _currentFlock,
                  currentPlan: _currentPlan,
                  currentWeek: _currentWeek,
                  completedTasks: _completedTasks,
                  totalTasks: _totalTasks,
                ),
        backgroundColor: AppColors.leakukuGreen,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : null,
        label: _isSaving
            ? const SizedBox.shrink()
            : const Text('Save Today\'s Record'),
      ),
    );
  }

  Future<void> _saveRecord({
    required FlockModel flock,
    required WeeklyPlanModel? currentPlan,
    required int currentWeek,
    required int completedTasks,
    required int totalTasks,
  }) async {
    final feedKg = double.tryParse(_feedController.text.trim());
    final waterRefills = int.tryParse(_waterRefillsController.text) ?? 0;
    final mortalityCount = int.tryParse(_mortalityController.text) ?? 0;
    final actualWeight = double.tryParse(_weightController.text.trim());

    if (mortalityCount < 0) {
      _showMessage('Mortality cannot be negative.');
      return;
    }

    if (mortalityCount > flock.quantity) {
      _showMessage('Mortality cannot be more than birds alive.');
      return;
    }

    if (feedKg != null && feedKg < 0) {
      _showMessage('Feed given cannot be negative.');
      return;
    }

    if (actualWeight != null && actualWeight < 0) {
      _showMessage('Weight cannot be negative.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final tasks = _taskStateByFlock[flock.id] ?? const <String, bool>{};
      final updatedQuantity = flock.quantity - mortalityCount;
      final dailyNote = _progressService.buildDailyNote(
        date: DateTime.now(),
        healthStatus: _healthStatus,
        healthNotes: _healthNotesController.text.trim(),
        waterRefills: waterRefills,
        mortalityNotes: _mortalityNotesController.text.trim(),
        generalNotes: _generalNotesController.text.trim(),
        completedTasks: completedTasks,
        totalTasks: totalTasks,
        completedTaskTitles: tasks.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
      );

      final updatedFlock = FlockModel(
        id: flock.id,
        name: flock.name,
        breed: flock.breed,
        quantity: updatedQuantity,
        purchaseDate: flock.purchaseDate,
        userId: flock.userId,
        notes: _progressService.mergeDailyRecordNote(flock.notes, dailyNote),
      );

      await ref.read(flockProvider.notifier).updateFlock(updatedFlock);

      final planToUpdate = currentPlan ??
          await ref
              .read(weeklyPlanDataSourceProvider)
              .getWeekPlan(flock.id, currentWeek);

      if (planToUpdate != null) {
        final startingBirds = flock.quantity == 0 ? 1 : flock.quantity;
        final updatedPlan = WeeklyPlanModel(
          id: planToUpdate.id,
          flockId: planToUpdate.flockId,
          weekNumber: planToUpdate.weekNumber,
          plannedFeedGramsPerBird: planToUpdate.plannedFeedGramsPerBird,
          plannedTotalFeedKg: planToUpdate.plannedTotalFeedKg,
          plannedWaterLiters: planToUpdate.plannedWaterLiters,
          plannedBodyWeightKg: planToUpdate.plannedBodyWeightKg,
          plannedTemperatureCelsius: planToUpdate.plannedTemperatureCelsius,
          plannedMortalityPercent: planToUpdate.plannedMortalityPercent,
          actualFeedGramsPerBird: feedKg == null
              ? planToUpdate.actualFeedGramsPerBird
              : (feedKg * 1000) / startingBirds,
          actualTotalFeedKg: feedKg ?? planToUpdate.actualTotalFeedKg,
          actualWaterLiters: planToUpdate.actualWaterLiters,
          actualBodyWeightKg: actualWeight ?? planToUpdate.actualBodyWeightKg,
          actualTemperatureCelsius: planToUpdate.actualTemperatureCelsius,
          actualMortalityPercent: startingBirds == 0
              ? planToUpdate.actualMortalityPercent
              : (mortalityCount / startingBirds) * 100,
          weekStartDate: planToUpdate.weekStartDate,
        );

        await ref
            .read(weeklyPlanDataSourceProvider)
            .updateWeekActuals(updatedPlan);
      }

      ref.invalidate(weeklyPlansProvider(flock.id));

      if (!mounted) {
        return;
      }

      _showMessage('Today\'s record has been saved.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not save today\'s record.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _syncDraftState({
    required FlockModel flock,
    required WeeklyPlanModel? currentPlan,
    required List<DailyTask> tasks,
    required int currentWeek,
  }) {
    final draftKey = '${flock.id}-$currentWeek';
    final existingTaskState = _taskStateByFlock[flock.id] ?? <String, bool>{};
    _taskStateByFlock[flock.id] = {
      for (final task in tasks)
        task.title: existingTaskState[task.title] ?? false,
    };

    if (_loadedDraftKey == draftKey) {
      return;
    }

    _loadedDraftKey = draftKey;
    _feedController.text =
        currentPlan?.actualTotalFeedKg?.toStringAsFixed(1) ?? '';
    _weightController.text =
        currentPlan?.actualBodyWeightKg?.toStringAsFixed(2) ?? '';
    _mortalityController.text = currentPlan?.actualMortalityPercent == null
        ? ''
        : _progressService
            .estimateMortalityCount(
              flock.quantity,
              currentPlan!.actualMortalityPercent!,
            )
            .toString();

    final persistedDraft =
        _progressService.extractDailyRecordDraft(flock.notes, DateTime.now());
    _waterRefillsController.text = persistedDraft.waterRefills ?? '';
    _healthStatus = persistedDraft.healthStatus ?? 'Healthy';
    _healthNotesController.text = persistedDraft.healthNotes ?? '';
    _mortalityNotesController.text = persistedDraft.mortalityNotes ?? '';
    _generalNotesController.text = persistedDraft.generalNotes ?? '';
  }
}
