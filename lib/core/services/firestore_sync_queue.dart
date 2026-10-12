import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Durable outbox for local-first writes that need a Firestore retry.
class FirestoreSyncQueue {
  FirestoreSyncQueue({
    required Box<Map<dynamic, dynamic>> queueBox,
    FirebaseFirestore? firestore,
  })  : _queueBox = queueBox,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final Box<Map<dynamic, dynamic>> _queueBox;
  final FirebaseFirestore _firestore;
  Future<void>? _activeFlush;

  Future<void> upsert({
    required String uid,
    required String collection,
    required String id,
    required Map<String, dynamic> data,
    String? parentCollection,
    String? parentId,
  }) async {
    await _enqueue(
      uid,
      collection,
      id,
      'upsert',
      data,
      parentCollection: parentCollection,
      parentId: parentId,
    );
  }

  Future<void> delete({
    required String uid,
    required String collection,
    required String id,
    String? parentCollection,
    String? parentId,
  }) async {
    await _enqueue(
      uid,
      collection,
      id,
      'delete',
      const {},
      parentCollection: parentCollection,
      parentId: parentId,
    );
  }

  Future<void> _enqueue(
    String uid,
    String collection,
    String id,
    String operation,
    Map<String, dynamic> data, {
    String? parentCollection,
    String? parentId,
  }) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError.value(uid, 'uid', 'A signed-in user is required.');
    }

    final key = _queueKey(
      uid,
      collection,
      id,
      parentCollection: parentCollection,
      parentId: parentId,
    );
    await _queueBox.put(key, {
      'uid': uid,
      'collection': collection,
      'id': id,
      if (parentCollection != null) 'parentCollection': parentCollection,
      if (parentId != null) 'parentId': parentId,
      'operation': operation,
      'data': data,
    });
    unawaited(flush());
  }

  Future<void> flush() {
    final active = _activeFlush;
    if (active != null) return active;

    final flushFuture = _flushPending();
    _activeFlush = flushFuture;
    return flushFuture.whenComplete(() => _activeFlush = null);
  }

  Future<void> _flushPending() async {
    for (final key in _queueBox.keys.toList()) {
      final operation = _queueBox.get(key);
      if (operation == null) continue;

      try {
        final uid = operation['uid'] as String;
        final collection = operation['collection'] as String;
        final id = operation['id'] as String;
        final parentCollection = operation['parentCollection'] as String?;
        final parentId = operation['parentId'] as String?;
        var parent = _firestore.collection('users').doc(uid);
        if (parentCollection != null && parentId != null) {
          parent = parent.collection(parentCollection).doc(parentId);
        }
        final document = parent.collection(collection).doc(id);
        final tombstoneScope = [
          if (parentCollection != null) parentCollection,
          if (parentId != null) parentId,
          collection,
          id,
        ].join('/');
        final tombstone = _firestore
            .collection('users')
            .doc(uid)
            .collection('_syncTombstones')
            .doc(Uri.encodeComponent(tombstoneScope));

        if (operation['operation'] == 'delete') {
          await tombstone.set({
            'collection': collection,
            if (parentCollection != null) 'parentCollection': parentCollection,
            if (parentId != null) 'parentId': parentId,
            'id': id,
            'deletedAt': FieldValue.serverTimestamp(),
          });
          await document.delete();
        } else {
          final data = Map<String, dynamic>.from(
            operation['data'] as Map<dynamic, dynamic>,
          );
          await document.set(data, SetOptions(merge: true));
          await tombstone.delete();
        }
        await _queueBox.delete(key);
      } catch (error, stackTrace) {
        debugPrint('Firestore sync paused; queued writes will retry: $error');
        debugPrintStack(stackTrace: stackTrace);
        return;
      }
    }
  }

  int get pendingCount => _queueBox.length;

  bool hasPendingOperation(
    String uid,
    String collection,
    String id, {
    String? parentCollection,
    String? parentId,
  }) =>
      _queueBox.containsKey(
        _queueKey(
          uid,
          collection,
          id,
          parentCollection: parentCollection,
          parentId: parentId,
        ),
      );

  bool hasPendingDelete(
    String uid,
    String collection,
    String id, {
    String? parentCollection,
    String? parentId,
  }) =>
      _queueBox.get(
        _queueKey(
          uid,
          collection,
          id,
          parentCollection: parentCollection,
          parentId: parentId,
        ),
      )?['operation'] ==
      'delete';

  Future<Map<String, Set<String>>> readTombstones(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('_syncTombstones')
        .get();
    final tombstones = <String, Set<String>>{};
    for (final document in snapshot.docs) {
      final collection = document.data()['collection'];
      final id = document.data()['id'];
      if (collection is String && id is String) {
        final parentCollection = document.data()['parentCollection'];
        final parentId = document.data()['parentId'];
        final scope = tombstoneScope(
          collection,
          parentCollection:
              parentCollection is String ? parentCollection : null,
          parentId: parentId is String ? parentId : null,
        );
        tombstones.putIfAbsent(scope, () => <String>{}).add(id);
      }
    }
    return tombstones;
  }

  static String tombstoneScope(
    String collection, {
    String? parentCollection,
    String? parentId,
  }) =>
      [
        if (parentCollection != null) parentCollection,
        if (parentId != null) parentId,
        collection,
      ].join('/');

  String _queueKey(
    String uid,
    String collection,
    String id, {
    String? parentCollection,
    String? parentId,
  }) =>
      [
        uid,
        if (parentCollection != null) parentCollection,
        if (parentId != null) parentId,
        collection,
        id,
      ].join('/');
}
