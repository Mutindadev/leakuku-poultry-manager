import 'package:cloud_firestore/cloud_firestore.dart';

typedef FirestoreModelDecoder<T> = T Function(Map<String, dynamic> data);
typedef FirestoreModelEncoder<T> = Map<String, dynamic> Function(T value);

class FirestoreCollections {
  static const flocks = 'flocks';
  static const stockItems = 'stockItems';
  static const stockHistory = 'stockHistory';
  static const financialTransactions = 'financialTransactions';
  static const vaccines = 'vaccines';
  static const weeklyPlans = 'weeklyPlans';

  const FirestoreCollections._();
}

/// CRUD access to a single user-owned Firestore subcollection.
class FirestoreCollectionDataSource<T> {
  FirestoreCollectionDataSource({
    required this.collectionName,
    required this.decode,
    required this.encode,
    this.parentCollection,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final String collectionName;
  final FirestoreModelDecoder<T> decode;
  final FirestoreModelEncoder<T> encode;
  final String? parentCollection;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(
    String uid, {
    String? parentId,
  }) {
    if (uid.trim().isEmpty) {
      throw ArgumentError.value(uid, 'uid', 'A signed-in user is required.');
    }
    var parent = _firestore.collection('users').doc(uid);
    if (parentCollection != null) {
      if (parentId == null || parentId.isEmpty) {
        throw ArgumentError.value(
          parentId,
          'parentId',
          'A parent document is required for this collection.',
        );
      }
      parent = parent.collection(parentCollection!).doc(parentId);
    } else if (parentId != null) {
      throw ArgumentError.value(
        parentId,
        'parentId',
        'This collection does not have a parent document.',
      );
    }
    return parent.collection(collectionName);
  }

  Future<void> create(
    String uid,
    String id,
    T value, {
    String? parentId,
  }) async {
    await _collection(uid, parentId: parentId)
        .doc(id)
        .set(_documentData(id, value));
    await _tombstone(uid, id, parentId: parentId).delete();
  }

  Future<T?> read(String uid, String id, {String? parentId}) async {
    final snapshot = await _collection(uid, parentId: parentId).doc(id).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return decode({...data, 'id': data['id'] ?? snapshot.id});
  }

  Future<List<T>> readAll(String uid, {String? parentId}) async {
    final snapshot = await _collection(uid, parentId: parentId).get();
    return snapshot.docs
        .map((doc) => decode({...doc.data(), 'id': doc.data()['id'] ?? doc.id}))
        .toList(growable: false);
  }

  Stream<List<T>> watchAll(String uid, {String? parentId}) {
    return _collection(uid, parentId: parentId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  decode({...doc.data(), 'id': doc.data()['id'] ?? doc.id}))
              .toList(growable: false),
        );
  }

  Future<void> update(
    String uid,
    String id,
    T value, {
    String? parentId,
  }) async {
    await _collection(uid, parentId: parentId)
        .doc(id)
        .update(_documentData(id, value));
    await _tombstone(uid, id, parentId: parentId).delete();
  }

  Future<void> delete(String uid, String id, {String? parentId}) async {
    await _tombstone(uid, id, parentId: parentId).set({
      'collection': collectionName,
      if (parentCollection != null) 'parentCollection': parentCollection,
      if (parentId != null) 'parentId': parentId,
      'id': id,
      'deletedAt': FieldValue.serverTimestamp(),
    });
    await _collection(uid, parentId: parentId).doc(id).delete();
  }

  DocumentReference<Map<String, dynamic>> _tombstone(
    String uid,
    String id, {
    String? parentId,
  }) {
    final scope = [
      if (parentCollection != null) parentCollection!,
      if (parentId != null) parentId,
      collectionName,
      id,
    ].join('/');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('_syncTombstones')
        .doc(Uri.encodeComponent(scope));
  }

  Map<String, dynamic> _documentData(String id, T value) => {
        ...encode(value),
        'id': id,
      };
}
