import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:leakuku/core/services/firestore_sync_queue.dart';
import 'package:leakuku/features/progress/data/models/daily_task_config.dart';
import 'package:leakuku/features/progress/presentation/providers/daily_task_catalog_provider.dart';

class _FakeFirestoreSyncQueue implements FirestoreSyncQueue {
  final List<Map<String, dynamic>> upserts = [];
  final List<String> deletedIds = [];

  @override
  Future<void> upsert({
    required String uid,
    required String collection,
    required String id,
    required Map<String, dynamic> data,
    String? parentCollection,
    String? parentId,
  }) async {
    upserts.add({'uid': uid, 'collection': collection, 'id': id, 'data': data});
  }

  @override
  Future<void> delete({
    required String uid,
    required String collection,
    required String id,
    String? parentCollection,
    String? parentId,
  }) async {
    deletedIds.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory directory;
  late Box<Map<dynamic, dynamic>> box;
  late _FakeFirestoreSyncQueue syncQueue;
  late DailyTaskCatalogNotifier notifier;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp();
    Hive.init(directory.path);
    box = await Hive.openBox<Map<dynamic, dynamic>>('dailyTaskConfigBox');
    syncQueue = _FakeFirestoreSyncQueue();
    notifier = DailyTaskCatalogNotifier(
      userId: 'farmer-1',
      box: box,
      syncQueue: syncQueue,
    );
    await notifier.load();
  });

  tearDown(() async {
    notifier.dispose();
    await box.close();
    await Hive.deleteFromDisk();
    await directory.delete(recursive: true);
  });

  test('built-in tasks can be disabled and re-enabled, not deleted', () async {
    await notifier.setEnabled('invalid', false);
    expect(notifier.state.configurations, isEmpty);

    await notifier.setEnabled('builtin_feed_birds', false);
    final disabled = notifier.state.configurations.single;
    expect(disabled.isCustom, isFalse);
    expect(disabled.isEnabled, isFalse);

    await notifier.setEnabled('builtin_feed_birds', true);
    expect(notifier.state.configurations.single.isEnabled, isTrue);
    await expectLater(
      notifier.deleteCustomTask('builtin_feed_birds'),
      throwsA(isA<StateError>()),
    );
  });

  test('custom tasks support scope, disable, and deletion', () async {
    await notifier.addCustomTask(title: 'Collect eggs', flockId: null);
    final task = notifier.state.configurations.single;

    expect(task.isCustom, isTrue);
    expect(task.appliesTo('flock-1'), isTrue);

    await notifier.setEnabled(task.id, false);
    expect(notifier.state.configurations.single.isEnabled, isFalse);

    await notifier.deleteCustomTask(task.id);
    expect(notifier.state.configurations, isEmpty);
    expect(box.values, isEmpty);
    expect(syncQueue.deletedIds, [task.id]);
  });

  test('task config round-trips its flock scope and enabled state', () {
    final config = DailyTaskConfig(
      id: 'custom-1',
      userId: 'farmer-1',
      title: 'Check nest boxes',
      flockId: 'flock-1',
      isCustom: true,
      isEnabled: false,
      updatedAt: DateTime(2026, 10, 29),
    );
    final restored = DailyTaskConfig.fromMap(config.toMap());

    expect(restored.title, config.title);
    expect(restored.flockId, 'flock-1');
    expect(restored.appliesTo('flock-1'), isTrue);
    expect(restored.appliesTo('flock-2'), isFalse);
    expect(restored.isEnabled, isFalse);
  });

  test('custom task names cannot corrupt daily checklist notes', () async {
    await expectLater(
      notifier.addCustomTask(title: 'Collect, count', flockId: null),
      throwsArgumentError,
    );
    expect(notifier.state.configurations, isEmpty);
  });

  test('reloads task settings written by Firestore sync', () async {
    final loaded = Completer<void>();
    notifier.addListener((state) {
      if (state.configurations.any((config) => config.id == 'custom-remote') &&
          !loaded.isCompleted) {
        loaded.complete();
      }
    });

    final remoteConfig = DailyTaskConfig(
      id: 'custom-remote',
      userId: 'farmer-1',
      title: 'Check the brooder',
      isCustom: true,
      isEnabled: true,
      updatedAt: DateTime(2026),
    );
    await box.put('farmer-1/custom-remote', remoteConfig.toMap());
    await loaded.future.timeout(const Duration(seconds: 2));

    expect(notifier.state.configurations.single.id, 'custom-remote');
  });
}
