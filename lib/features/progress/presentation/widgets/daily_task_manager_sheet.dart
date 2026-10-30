import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';
import 'package:leakuku/features/progress/data/models/daily_task_config.dart';
import 'package:leakuku/features/progress/presentation/providers/daily_task_catalog_provider.dart';
import 'package:leakuku/features/user/presentation/provider/user_provider.dart';

Future<void> showDailyTaskManager(
  BuildContext context,
  WidgetRef ref, {
  required List<FlockModel> flocks,
}) async {
  final userId = ref.read(userProvider).userModel?.uid;
  if (userId == null || userId.isEmpty) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DailyTaskManagerSheet(userId: userId, flocks: flocks),
  );
}

class DailyTaskManagerSheet extends ConsumerStatefulWidget {
  const DailyTaskManagerSheet({
    super.key,
    required this.userId,
    required this.flocks,
  });

  final String userId;
  final List<FlockModel> flocks;

  @override
  ConsumerState<DailyTaskManagerSheet> createState() =>
      _DailyTaskManagerSheetState();
}

class _DailyTaskManagerSheetState extends ConsumerState<DailyTaskManagerSheet> {
  static const _wholeFarm = '__whole_farm__';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _flockSelection = _wholeFarm;
  bool _isAdding = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isAdding = true);
    try {
      await ref
          .read(dailyTaskCatalogProvider(widget.userId).notifier)
          .addCustomTask(
            title: _titleController.text,
            flockId: _flockSelection == _wholeFarm ? null : _flockSelection,
          );
      _titleController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _deleteTask(DailyTaskConfig task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete custom task?'),
        content: Text('“${task.title}” will be removed from your daily list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(dailyTaskCatalogProvider(widget.userId).notifier)
          .deleteCustomTask(task.id);
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(dailyTaskCatalogProvider(widget.userId));
    final configurations = {
      for (final config in catalog.configurations) config.id: config,
    };

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.86,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manage daily tasks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.earthCharcoal,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Text(
                    'Add a recurring task',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          maxLength: 60,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Task name',
                            hintText: 'e.g. Collect eggs',
                            counterText: '',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter a task name'
                                  : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: _flockSelection,
                          decoration:
                              const InputDecoration(labelText: 'Applies to'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: _wholeFarm,
                              child: Text('Whole farm'),
                            ),
                            ...widget.flocks.map(
                              (flock) => DropdownMenuItem<String>(
                                value: flock.id,
                                child: Text(flock.name),
                              ),
                            ),
                          ],
                          onChanged: (value) => setState(
                            () => _flockSelection = value ?? _wholeFarm,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isAdding ? null : _addTask,
                            icon: const Icon(Icons.add),
                            label: Text(_isAdding ? 'Adding…' : 'Add task'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'App tasks',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const Text('On'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (final entry in builtInDailyTaskTitles.entries)
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.value),
                      value: configurations[builtInTaskConfigId(entry.key)]
                              ?.isEnabled ??
                          true,
                      onChanged: (enabled) => ref
                          .read(
                              dailyTaskCatalogProvider(widget.userId).notifier)
                          .setEnabled(
                            builtInTaskConfigId(entry.key),
                            enabled,
                          ),
                    ),
                  const Divider(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Your tasks',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const Text('On'),
                    ],
                  ),
                  if (catalog.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (catalog.configurations
                      .where((config) => config.isCustom)
                      .isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Your custom tasks will appear here.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.softGray,
                            ),
                      ),
                    )
                  else
                    for (final task in catalog.configurations
                        .where((config) => config.isCustom))
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(task.title),
                        subtitle: Text(_scopeLabel(task)),
                        value: task.isEnabled,
                        onChanged: (enabled) => ref
                            .read(dailyTaskCatalogProvider(widget.userId)
                                .notifier)
                            .setEnabled(task.id, enabled),
                        secondary: IconButton(
                          tooltip: 'Delete custom task',
                          onPressed: () => _deleteTask(task),
                          icon: const Icon(Icons.delete_outline),
                          color: AppColors.errorRed,
                        ),
                      ),
                  if (catalog.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      catalog.error!,
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _scopeLabel(DailyTaskConfig task) {
    if (task.flockId == null) return 'Whole farm';
    for (final flock in widget.flocks) {
      if (flock.id == task.flockId) return flock.name;
    }
    return 'Flock no longer available';
  }
}
