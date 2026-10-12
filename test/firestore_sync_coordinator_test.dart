import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leakuku/core/services/firestore_sync_coordinator.dart';

void main() {
  test('syncs on sign-in and when connectivity returns', () async {
    final userIds = StreamController<String?>();
    final connectivity = StreamController<ConnectivityResult>();
    final syncedUsers = <String>[];
    var currentUserId = 'farmer-1';
    final coordinator = FirestoreSyncCoordinator(
      userIdChanges: userIds.stream,
      connectivityChanges: connectivity.stream,
      currentUserId: () => currentUserId,
      syncUser: (userId) async => syncedUsers.add(userId),
      interval: const Duration(days: 1),
    );

    userIds.add(currentUserId);
    await Future<void>.delayed(Duration.zero);
    connectivity.add(ConnectivityResult.none);
    await Future<void>.delayed(Duration.zero);
    expect(syncedUsers, ['farmer-1']);

    connectivity.add(ConnectivityResult.wifi);
    await Future<void>.delayed(Duration.zero);
    expect(syncedUsers, ['farmer-1', 'farmer-1']);

    currentUserId = 'farmer-2';
    userIds.add(currentUserId);
    await Future<void>.delayed(Duration.zero);
    expect(syncedUsers, ['farmer-1', 'farmer-1', 'farmer-2']);

    coordinator.dispose();
    await userIds.close();
    await connectivity.close();
  });

  test('syncNow completes after the requested user sync', () async {
    final userIds = StreamController<String?>();
    final connectivity = StreamController<ConnectivityResult>();
    final completion = Completer<void>();
    final coordinator = FirestoreSyncCoordinator(
      userIdChanges: userIds.stream,
      connectivityChanges: connectivity.stream,
      currentUserId: () => 'farmer-1',
      syncUser: (_) => completion.future,
      interval: const Duration(days: 1),
    );

    var finished = false;
    final sync = coordinator.syncNow('farmer-1').then((_) => finished = true);
    await Future<void>.delayed(Duration.zero);
    expect(finished, isFalse);

    completion.complete();
    await sync;
    expect(finished, isTrue);

    coordinator.dispose();
    await userIds.close();
    await connectivity.close();
  });

  test('syncNow reports failures to its caller', () async {
    final userIds = StreamController<String?>();
    final connectivity = StreamController<ConnectivityResult>();
    final coordinator = FirestoreSyncCoordinator(
      userIdChanges: userIds.stream,
      connectivityChanges: connectivity.stream,
      currentUserId: () => 'farmer-1',
      syncUser: (_) async => throw StateError('offline'),
      interval: const Duration(days: 1),
    );

    await expectLater(
      coordinator.syncNow('farmer-1'),
      throwsA(isA<StateError>()),
    );

    coordinator.dispose();
    await userIds.close();
    await connectivity.close();
  });
}
