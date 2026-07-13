import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/services/feeding_calculator.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/presentation/providers/vaccine_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

class ProgressPage extends ConsumerStatefulWidget {
  final bool showAppBar;

  const ProgressPage({super.key, this.showAppBar = false});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> {
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

    if (flockState.isLoading && flocks.isEmpty) {
      return _wrapPage(
        context,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.leakukuGreen),
        ),
      );
    }

    if (flocks.isEmpty) {
      return _wrapPage(
        context,
        body: _EmptyDailyRecordsState(showAppBar: widget.showAppBar),
      );
    }

    final flock = selectedFlock ?? flocks.first;
    final ageDays = DateTime.now().difference(flock.purchaseDate).inDays;
    final stage = _getStage(ageDays);
    final currentWeek = ageDays < 0 ? 1 : (ageDays ~/ 7) + 1;
    final weeklyPlansAsync = ref.watch(weeklyPlansProvider(flock.id));
    final vaccineScheduleAsync = ref.watch(vaccineScheduleProvider(flock.id));

    final plans = weeklyPlansAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <WeeklyPlanModel>[],
    );
    final currentPlan = _findCurrentPlan(plans, currentWeek);
    final vaccines = vaccineScheduleAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const [],
    );
    final tasks = _buildTasks(
      stage: stage,
      currentPlan: currentPlan,
      dueVaccinesToday: _dueVaccinesToday(flock.purchaseDate, vaccines),
    );

    _syncDraftState(
      flock: flock,
      currentPlan: currentPlan,
      tasks: tasks,
      currentWeek: currentWeek,
    );

    final taskState = _taskStateByFlock[flock.id] ?? const <String, bool>{};
    final completedTasks = taskState.values.where((value) => value).length;

    final body = Container(
      color: AppColors.farmCream,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildHeaderCard(
                  context,
                  flock: flock,
                  ageDays: ageDays,
                  stage: stage,
                  completedTasks: completedTasks,
                  totalTasks: tasks.length,
                  allFlocks: flocks,
                ),
                const SizedBox(height: 16),
                _buildPlanCard(context, flock.id, tasks, taskState),
                const SizedBox(height: 16),
                _buildRecordCard(
                  context,
                  flock: flock,
                  currentPlan: currentPlan,
                  ageDays: ageDays,
                  weeklyPlansLoading: weeklyPlansAsync.isLoading,
                ),
              ],
            ),
          ),
          _buildSaveBar(
            context,
            flock: flock,
            currentPlan: currentPlan,
            currentWeek: currentWeek,
            completedTasks: completedTasks,
            totalTasks: tasks.length,
          ),
        ],
      ),
    );

    return _wrapPage(context, body: body);
  }

  Widget _wrapPage(BuildContext context, {required Widget body}) {
    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: AppColors.farmCream,
        appBar: AppBar(title: const Text('Daily Records')),
        body: body,
      );
    }

    return body;
  }

  Widget _buildHeaderCard(
    BuildContext context, {
    required FlockModel flock,
    required int ageDays,
    required String stage,
    required int completedTasks,
    required int totalTasks,
    required List<FlockModel> allFlocks,
  }) {
    final progressLabel = '$completedTasks of $totalTasks tasks completed';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (allFlocks.length > 1) ...[
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                key: ValueKey(flock.id),
                initialValue: flock.id,
                decoration: InputDecoration(
                  labelText: 'Current batch',
                  filled: true,
                  fillColor: AppColors.farmCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: allFlocks
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  ref.read(selectedFlockIdProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 18),
            ] else ...[
              const SizedBox(height: 4),
            ],
            Text(
              flock.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthCharcoal,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatAgeLabel(ageDays)} • $stage Stage',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_formatWholeNumber(flock.quantity)} Birds Alive',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthCharcoal,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.farmCream,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.listCheck,
                        color: AppColors.leakukuGreen,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Progress',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          progressLabel,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value:
                              totalTasks == 0 ? 0 : completedTasks / totalTasks,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.leakukuGreen,
                          strokeWidth: 5,
                        ),
                        Center(
                          child: Text(
                            '$completedTasks',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String flockId,
    List<_DailyTask> tasks,
    Map<String, bool> taskState,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Plan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthCharcoal,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Follow the checklist and mark each job as you complete it.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 14),
            ...tasks.map(
              (task) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.farmCream,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CheckboxListTile(
                  value: taskState[task.title] ?? false,
                  onChanged: (value) {
                    setState(() {
                      final flockTasks =
                          _taskStateByFlock[flockId] ?? <String, bool>{};
                      flockTasks[task.title] = value ?? false;
                      _taskStateByFlock[flockId] = flockTasks;
                    });
                  },
                  activeColor: AppColors.leakukuGreen,
                  controlAffinity: ListTileControlAffinity.leading,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  title: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: (taskState[task.title] ?? false)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                  subtitle: task.subtitle == null
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(task.subtitle!),
                        ),
                  secondary: FaIcon(task.icon, color: task.color, size: 16),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context, {
    required FlockModel flock,
    required WeeklyPlanModel? currentPlan,
    required int ageDays,
    required bool weeklyPlansLoading,
  }) {
    final recommendedFeedKg = flock.quantity == 0
        ? 0.0
        : (FeedingCalculator.getDailyFoodGrams(flock.breed, ageDays) *
                flock.quantity) /
            1000;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Record',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthCharcoal,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Record only what changed today so the batch stays accurate.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
            ),
            if (weeklyPlansLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(color: AppColors.leakukuGreen),
            ],
            const SizedBox(height: 18),
            _buildRecordSection(
              context,
              title: 'Feed',
              helper: currentPlan != null
                  ? 'Recommended today: ${currentPlan.plannedTotalFeedKg.toStringAsFixed(1)} kg total'
                  : 'Recommended today: ${recommendedFeedKg.toStringAsFixed(1)} kg total',
              child: _numberField(
                controller: _feedController,
                label: 'Actual feed given (kg)',
                hint: 'Enter total feed given today',
              ),
            ),
            _buildRecordSection(
              context,
              title: 'Water',
              helper: currentPlan != null
                  ? 'Planned water use this week: ${currentPlan.plannedWaterLiters.toStringAsFixed(1)} L'
                  : 'Record how many times drinkers were refilled today.',
              child: _numberField(
                controller: _waterRefillsController,
                label: 'Number of water refills',
                hint: 'Enter refills completed today',
                decimals: false,
              ),
            ),
            _buildRecordSection(
              context,
              title: 'Health Check',
              helper: 'Choose the status that best matches the flock today.',
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Healthy', 'Slight concern', 'Needs attention']
                        .map(
                          (status) => ChoiceChip(
                            label: Text(status),
                            selected: _healthStatus == status,
                            selectedColor:
                                AppColors.leakukuGreen.withValues(alpha: 0.18),
                            onSelected: (_) {
                              setState(() {
                                _healthStatus = status;
                                if (_healthStatus != 'Needs attention') {
                                  _healthNotesController.clear();
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  if (_healthStatus == 'Needs attention') ...[
                    const SizedBox(height: 12),
                    _textField(
                      controller: _healthNotesController,
                      label: 'Health notes (optional)',
                      hint: 'Describe what needs attention',
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
            ),
            _buildRecordSection(
              context,
              title: 'Mortality',
              helper: 'Saving mortality updates birds alive for this batch.',
              child: Column(
                children: [
                  _numberField(
                    controller: _mortalityController,
                    label: 'Number of birds lost today',
                    hint: 'Enter birds lost today',
                    decimals: false,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _mortalityNotesController,
                    label: 'Notes (optional)',
                    hint: 'Anything unusual about today\'s losses',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            _buildRecordSection(
              context,
              title: 'Weight',
              helper: currentPlan != null
                  ? 'Expected weight: ${currentPlan.plannedBodyWeightKg.toStringAsFixed(2)} kg'
                  : 'Expected weight will appear when the growth plan is available.',
              child: _numberField(
                controller: _weightController,
                label: 'Actual recorded weight (kg)',
                hint: 'Enter sample or average recorded weight',
              ),
            ),
            _buildRecordSection(
              context,
              title: 'General Notes',
              helper: 'Use this for anything different that happened today.',
              child: _textField(
                controller: _generalNotesController,
                label: 'Notes (optional)',
                hint:
                    'Cold weather, leftovers, curtain changes, or any unusual event',
                maxLines: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordSection(
    BuildContext context, {
    required String title,
    required String helper,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool decimals = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimals),
      decoration: _inputDecoration(label: label, hint: hint),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label: label, hint: hint),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required String hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.farmCream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildSaveBar(
    BuildContext context, {
    required FlockModel flock,
    required WeeklyPlanModel? currentPlan,
    required int currentWeek,
    required int completedTasks,
    required int totalTasks,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _isSaving
              ? null
              : () => _saveRecord(
                    context,
                    flock: flock,
                    currentPlan: currentPlan,
                    currentWeek: currentWeek,
                    completedTasks: completedTasks,
                    totalTasks: totalTasks,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.leakukuGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text('Save Today\'s Record'),
        ),
      ),
    );
  }

  Future<void> _saveRecord(
    BuildContext context, {
    required FlockModel flock,
    required WeeklyPlanModel? currentPlan,
    required int currentWeek,
    required int completedTasks,
    required int totalTasks,
  }) async {
    final feedKg = _parseDouble(_feedController.text);
    final waterRefills = _parseInt(_waterRefillsController.text);
    final mortalityCount = _parseInt(_mortalityController.text) ?? 0;
    final actualWeight = _parseDouble(_weightController.text);

    if (mortalityCount < 0) {
      _showMessage(context, 'Mortality cannot be negative.');
      return;
    }

    if (mortalityCount > flock.quantity) {
      _showMessage(context, 'Mortality cannot be more than birds alive.');
      return;
    }

    if (feedKg != null && feedKg < 0) {
      _showMessage(context, 'Feed given cannot be negative.');
      return;
    }

    if (actualWeight != null && actualWeight < 0) {
      _showMessage(context, 'Weight cannot be negative.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final tasks = _taskStateByFlock[flock.id] ?? const <String, bool>{};
      final updatedQuantity = flock.quantity - mortalityCount;
      final dailyNote = _buildDailyNote(
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
        notes: _mergeDailyRecordNote(flock.notes, dailyNote),
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

      _showMessage(this.context, 'Today\'s record has been saved.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(this.context, 'Could not save today\'s record.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _syncDraftState({
    required FlockModel flock,
    required WeeklyPlanModel? currentPlan,
    required List<_DailyTask> tasks,
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
        : _estimateMortalityCount(
            flock.quantity,
            currentPlan!.actualMortalityPercent!,
          ).toString();

    final persistedDraft =
        _extractDailyRecordDraft(flock.notes, DateTime.now());
    _waterRefillsController.text = persistedDraft.waterRefills ?? '';
    _healthStatus = persistedDraft.healthStatus ?? 'Healthy';
    _healthNotesController.text = persistedDraft.healthNotes ?? '';
    _mortalityNotesController.text = persistedDraft.mortalityNotes ?? '';
    _generalNotesController.text = persistedDraft.generalNotes ?? '';
  }

  int _estimateMortalityCount(int currentBirdsAlive, double mortalityPercent) {
    final base = currentBirdsAlive == 0 ? 1 : currentBirdsAlive;
    return ((mortalityPercent / 100) * base).round();
  }

  WeeklyPlanModel? _findCurrentPlan(
      List<WeeklyPlanModel> plans, int currentWeek) {
    for (final plan in plans) {
      if (plan.weekNumber == currentWeek) {
        return plan;
      }
    }
    return null;
  }

  List<_DailyTask> _buildTasks({
    required String stage,
    required WeeklyPlanModel? currentPlan,
    required int dueVaccinesToday,
  }) {
    final tasks = <_DailyTask>[
      _DailyTask(
        title: 'Feed birds',
        subtitle: currentPlan == null
            ? null
            : 'Target feed is ${currentPlan.plannedTotalFeedKg.toStringAsFixed(1)} kg today.',
        icon: FontAwesomeIcons.wheatAwn,
        color: AppColors.leakukuGreen,
      ),
      const _DailyTask(
        title: 'Refresh water',
        subtitle: 'Clean drinkers and refill fresh water.',
        icon: FontAwesomeIcons.glassWater,
        color: Colors.blue,
      ),
      const _DailyTask(
        title: 'Observe bird activity',
        subtitle: 'Watch appetite, movement, and comfort in the house.',
        icon: FontAwesomeIcons.eye,
        color: Colors.teal,
      ),
      const _DailyTask(
        title: 'Check litter',
        subtitle: 'Remove wet spots and keep the floor dry.',
        icon: FontAwesomeIcons.broom,
        color: Colors.brown,
      ),
      const _DailyTask(
        title: 'Record mortality',
        subtitle: 'Confirm any birds lost before you finish the day.',
        icon: FontAwesomeIcons.heartPulse,
        color: Colors.red,
      ),
      _DailyTask(
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
        _DailyTask(
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

  int _dueVaccinesToday(DateTime purchaseDate, List<dynamic> vaccines) {
    final now = DateTime.now();
    var count = 0;
    for (final vaccine in vaccines) {
      final dueDate =
          purchaseDate.add(Duration(days: vaccine.scheduleDayOffset));
      if (_isSameDate(dueDate, now)) {
        count++;
      }
    }
    return count;
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _getStage(int ageDays) {
    if (ageDays <= 21) {
      return 'Brooding';
    }
    if (ageDays <= 140) {
      return 'Growing';
    }
    return 'Production';
  }

  String _formatAgeLabel(int ageDays) {
    if (ageDays <= 0) {
      return 'Day 0';
    }
    return 'Day $ageDays';
  }

  String _formatWholeNumber(int value) {
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

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return double.tryParse(value.trim());
  }

  int? _parseInt(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return int.tryParse(value.trim());
  }

  String _buildDailyNote({
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
    final dateKey = _dateKey(date);
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

    return '[Daily Record $dateKey] ${parts.join(' | ')}';
  }

  String? _mergeDailyRecordNote(String? existingNotes, String dailyNote) {
    final lines = (existingNotes ?? '')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    final notePrefix = dailyNote.split(']').first;

    lines.removeWhere((line) => line.startsWith(notePrefix));
    lines.add(dailyNote);

    if (lines.isEmpty) {
      return null;
    }

    return lines.join('\n');
  }

  _PersistedDraft _extractDailyRecordDraft(String? notes, DateTime date) {
    final key = '[Daily Record ${_dateKey(date)}]';
    final lines = (notes ?? '').split('\n');
    String? line;

    for (final item in lines) {
      if (item.startsWith(key)) {
        line = item;
        break;
      }
    }

    if (line == null) {
      return const _PersistedDraft();
    }

    String? readValue(String prefix) {
      final sections = line!.split(' | ');
      for (final section in sections) {
        if (section.startsWith(prefix)) {
          return section.substring(prefix.length).trim();
        }
      }
      return null;
    }

    return _PersistedDraft(
      healthStatus: readValue('Health: '),
      waterRefills: readValue('Water refills: '),
      healthNotes: readValue('Health notes: '),
      mortalityNotes: readValue('Mortality notes: '),
      generalNotes: readValue('General notes: '),
    );
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _DailyTask {
  final String title;
  final String? subtitle;
  final FaIconData icon;
  final Color color;

  const _DailyTask({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _PersistedDraft {
  final String? healthStatus;
  final String? waterRefills;
  final String? healthNotes;
  final String? mortalityNotes;
  final String? generalNotes;

  const _PersistedDraft({
    this.healthStatus,
    this.waterRefills,
    this.healthNotes,
    this.mortalityNotes,
    this.generalNotes,
  });
}

class _EmptyDailyRecordsState extends StatelessWidget {
  final bool showAppBar;

  const _EmptyDailyRecordsState({required this.showAppBar});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      color: AppColors.farmCream,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.clipboardCheck,
                    size: 34,
                    color: AppColors.leakukuGreen,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No bird batch is ready for records yet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.earthCharcoal,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a batch in Birds first, then come back here to manage the day\'s work.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );

    if (showAppBar) {
      return Scaffold(
        backgroundColor: AppColors.farmCream,
        appBar: AppBar(title: const Text('Daily Records')),
        body: content,
      );
    }

    return content;
  }
}
