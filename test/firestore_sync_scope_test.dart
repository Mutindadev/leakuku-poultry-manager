import 'package:flutter_test/flutter_test.dart';
import 'package:leakuku/core/services/firestore_sync_queue.dart';

void main() {
  test('nested collection tombstones are scoped to their parent flock', () {
    expect(
      FirestoreSyncQueue.tombstoneScope(
        'weeklyPlans',
        parentCollection: 'flocks',
        parentId: 'flock-1',
      ),
      'flocks/flock-1/weeklyPlans',
    );
    expect(
      FirestoreSyncQueue.tombstoneScope('weeklyPlans'),
      'weeklyPlans',
    );
  });
}
