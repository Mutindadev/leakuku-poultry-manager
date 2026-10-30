import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/core/providers/firestore_data_providers.dart';
import 'package:leakuku/core/services/firestore_collection_data_source.dart';
import 'package:leakuku/core/services/firestore_sync_queue.dart';
import 'package:leakuku/features/progress/data/models/daily_task_config.dart';

class DailyTaskCatalogState {
  const DailyTaskCatalogState({
    this.configurations = const [],
    this.isLoading = false,
    this.error,
  });

  final List<DailyTaskConfig> configurations;
  final bool isLoading;
  final String? error;

  DailyTaskCatalogState copyWith({
    List<DailyTaskConfig>? configurations,
    bool? isLoading,
    String? error,
  }) {
    return DailyTaskCatalogState(
      configurations: configurations ?? this.configurations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DailyTaskCatalogNotifier extends StateNotifier<DailyTaskCatalogState> {
  DailyTaskCatalogNotifier({
    required this.userId,
    required Box<Map<dynamic, dynamic>> box,
    required this.syncQueue,
  })  : _box = box,
        super(const DailyTaskCatalogState(isLoading: true)) {
    _boxSubscription = _box.watch().listen((event) {
      if (event.key is String && (event.key as String).startsWith('$userId/')) {
        unawaited(load());
      }
    });
    unawaited(load());
  }

  final String userId;
  final Box<Map<dynamic, dynamic>> _box;
  final FirestoreSyncQueue syncQueue;
  late final StreamSubscription<BoxEvent> _boxSubscription;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final configurations = _box.values
          .map((value) => DailyTaskConfig.fromMap(
                Map<String, dynamic>.from(value),
              ))
          .where((config) => config.userId == userId)
          .toList()
        ..sort((left, right) => left.title.compareTo(right.title));
      state = state.copyWith(
        configurations: configurations,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> setEnabled(String taskId, bool enabled) async {
    final existing = state.configurations.where((item) => item.id == taskId);
    final current = existing.isEmpty ? null : existing.first;
    if (current != null && current.isEnabled == enabled) return;

    final builtInId = taskId.startsWith('builtin_')
        ? taskId.substring('builtin_'.length)
        : null;
    final isCustom = builtInId == null;
    if (current == null && isCustom) return;
    if (current != null && current.isCustom != isCustom) return;
    final title = current?.title ?? builtInDailyTaskTitles[builtInId];
    if (title == null) return;

    await _save(
      DailyTaskConfig(
        id: taskId,
        userId: userId,
        title: title,
        description: current?.description,
        flockId: current?.flockId,
        isCustom: isCustom,
        isEnabled: enabled,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> addCustomTask({
    required String title,
    required String? flockId,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Task title cannot be empty.');
    }
    if (normalizedTitle.contains(',') || normalizedTitle.contains('|')) {
      throw ArgumentError.value(
        title,
        'title',
        'Task names cannot contain commas or vertical bars.',
      );
    }
    final normalized = normalizedTitle.toLowerCase();
    if (builtInDailyTaskTitles.values
            .any((builtIn) => builtIn.toLowerCase() == normalized) ||
        state.configurations.any(
          (config) => config.title.trim().toLowerCase() == normalized,
        )) {
      throw ArgumentError.value(
        title,
        'title',
        'A task with this title already exists.',
      );
    }

    final now = DateTime.now();
    final taskId = 'custom_${now.microsecondsSinceEpoch}';
    await _save(
      DailyTaskConfig(
        id: taskId,
        userId: userId,
        title: normalizedTitle,
        flockId: flockId,
        isCustom: true,
        isEnabled: true,
        updatedAt: now,
      ),
    );
  }

  Future<void> deleteCustomTask(String taskId) async {
    final matching = state.configurations.where((item) => item.id == taskId);
    if (matching.isEmpty || !matching.first.isCustom) {
      throw StateError('Only custom tasks can be deleted.');
    }

    await syncQueue.delete(
      uid: userId,
      collection: FirestoreCollections.dailyTaskConfigs,
      id: taskId,
    );
    await _box.delete('$userId/$taskId');
    state = state.copyWith(
      configurations:
          state.configurations.where((item) => item.id != taskId).toList(),
      error: null,
    );
  }

  Future<void> _save(DailyTaskConfig config) async {
    final map = config.toMap();
    await _box.put('$userId/${config.id}', map);
    state = state.copyWith(
      configurations: [
        ...state.configurations.where((item) => item.id != config.id),
        config,
      ]..sort((left, right) => left.title.compareTo(right.title)),
      error: null,
    );
    try {
      await syncQueue.upsert(
        uid: userId,
        collection: FirestoreCollections.dailyTaskConfigs,
        id: config.id,
        data: map,
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    _boxSubscription.cancel();
    super.dispose();
  }
}

final dailyTaskCatalogProvider = StateNotifierProvider.family<
    DailyTaskCatalogNotifier, DailyTaskCatalogState, String>((ref, userId) {
  return DailyTaskCatalogNotifier(
    userId: userId,
    box: Hive.box<Map<dynamic, dynamic>>('dailyTaskConfigBox'),
    syncQueue: ref.watch(firestoreSyncQueueProvider),
  );
});
