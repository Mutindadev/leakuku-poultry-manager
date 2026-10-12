import 'package:flutter_test/flutter_test.dart';
import 'package:leakuku/features/flock/data/models/flock_model.dart';
import 'package:leakuku/features/user/data/models/user.dart';

void main() {
  test('user model decodes Firestore dynamic string lists', () {
    final user = UserModel(
      uid: 'farmer-1',
      phonenumber: '',
      email: 'farmer@example.com',
      name: 'Farmer',
      role: 'farmer',
      flockIds: const ['flock-1'],
      activeFlocks: const ['flock-1'],
      fcmToken: '',
      isOnline: false,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      lastSyncedAt: DateTime.utc(2026),
      lastLocalModifiedAt: DateTime.utc(2026),
    );
    final data = user.toMap()
      ..['flockIds'] = <dynamic>['flock-1', 'flock-2']
      ..['activeFlocks'] = <dynamic>['flock-2'];

    final decoded = UserModel.fromMap(data);

    expect(decoded.flockIds, ['flock-1', 'flock-2']);
    expect(decoded.activeFlocks, ['flock-2']);
  });

  test('flock model decodes Firestore dynamic string lists', () {
    final flock = FlockModel(
      id: 'flock-1',
      name: 'Broilers',
      breed: 'Broilers',
      quantity: 20,
      purchaseDate: DateTime.utc(2026),
      userId: 'farmer-1',
      status: 'active',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      startedAt: DateTime.utc(2026),
      currentWeek: 'Week 1',
      mortalityPercent: '0%',
      avgBirdWeightKg: '0.0',
      feedConsumedKg: '0.0',
      waterConsumedLiters: '0.0',
      lowStockItemsCount: '0',
      pendingVaccinesCount: '0',
      lastDailyRecordDate: '',
    );
    final data = flock.toMap()
      ..['vaccineIds'] = <dynamic>['vaccine-1']
      ..['weeklyPlanIds'] = <dynamic>['plan-1']
      ..['dailyRecordsIds'] = <dynamic>['record-1']
      ..['stockItemIds'] = <dynamic>['stock-1']
      ..['financeTransactionIds'] = <dynamic>['txn-1'];

    final decoded = FlockModel.fromMap(data);

    expect(decoded.vaccineIds, ['vaccine-1']);
    expect(decoded.weeklyPlanIds, ['plan-1']);
    expect(decoded.dailyRecordsIds, ['record-1']);
    expect(decoded.stockItemIds, ['stock-1']);
    expect(decoded.financeTransactionIds, ['txn-1']);
  });
}
