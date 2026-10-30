import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class FirestoreSyncCoordinator {
  FirestoreSyncCoordinator({
    required Stream<String?> userIdChanges,
    required Stream<ConnectivityResult> connectivityChanges,
    required String? Function() currentUserId,
    required Future<void> Function(String userId) syncUser,
    this.interval = const Duration(minutes: 15),
  })  : _currentUserId = currentUserId,
        _syncUser = syncUser {
    _userSubscription = userIdChanges.listen((userId) {
      if (userId != null) _sync(userId);
    });
    _connectivitySubscription = connectivityChanges.listen((result) {
      if (result != ConnectivityResult.none) _syncCurrentUser();
    });
    _timer = Timer.periodic(interval, (_) => _syncCurrentUser());
  }

  final Duration interval;
  final String? Function() _currentUserId;
  final Future<void> Function(String userId) _syncUser;
  late final StreamSubscription<String?> _userSubscription;
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late final Timer _timer;

  void _syncCurrentUser() {
    final userId = _currentUserId();
    if (userId != null) _sync(userId);
  }

  Future<void> syncNow(String userId) async {
    if (userId.trim().isEmpty) return;
    await _syncUser(userId);
  }

  Future<void> _sync(String userId) async {
    if (userId.trim().isEmpty) return;
    try {
      await _syncUser(userId);
    } catch (error) {
      debugPrint('Firestore sync will retry later: $error');
    }
  }

  void dispose() {
    _userSubscription.cancel();
    _connectivitySubscription.cancel();
    _timer.cancel();
  }
}
