import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leakuku/core/di.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/presentation/providers/auth_provider.dart';

class FlockState {
  final List<FlockModel> flocks;
  final bool isLoading;
  final String? error;

  FlockState({
    this.flocks = const [],
    this.isLoading = false,
    this.error,
  });

  FlockState copyWith({
    List<FlockModel>? flocks,
    bool? isLoading,
    String? error,
  }) {
    return FlockState(
      flocks: flocks ?? this.flocks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FlockNotifier extends StateNotifier<FlockState> {
  final Ref ref;

  FlockNotifier(this.ref) : super(FlockState());

  Future<void> loadFlocks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id ?? '';
      
      final dataSource = ref.read(flockLocalDataSourceProvider);
      final flocks = await dataSource.getAllFlocks(userId);
      
      state = state.copyWith(flocks: flocks, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addFlock(FlockModel flock) async {
    try {
      final dataSource = ref.read(flockLocalDataSourceProvider);
      await dataSource.addFlock(flock);
      await loadFlocks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateFlock(FlockModel flock) async {
    try {
      final dataSource = ref.read(flockLocalDataSourceProvider);
      await dataSource.updateFlock(flock);
      await loadFlocks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteFlock(String id) async {
    try {
      final dataSource = ref.read(flockLocalDataSourceProvider);
      await dataSource.deleteFlock(id);
      await loadFlocks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final flockProvider = StateNotifierProvider<FlockNotifier, FlockState>((ref) {
  return FlockNotifier(ref);
});

// Memoized selectors for performance
final flockStatsProvider = Provider<FlockStats>((ref) {
  final flocks = ref.watch(flockProvider).flocks;
  
  final totalFlocks = flocks.length;
  final totalChickens = flocks.fold<int>(0, (s, f) => s + f.quantity);
  final layers = flocks.where((f) => f.breed.toLowerCase() == 'layers').fold<int>(0, (s, f) => s + f.quantity);
  final broilers = flocks.where((f) => f.breed.toLowerCase() == 'broilers').fold<int>(0, (s, f) => s + f.quantity);
  final kienyeji = flocks.where((f) => f.breed.toLowerCase().contains('kienye')).fold<int>(0, (s, f) => s + f.quantity);
  
  // Calculate average age in days
  int avgAgeDays = 0;
  if (flocks.isNotEmpty) {
    final totalDays = flocks.fold<int>(0, (sum, f) {
      final age = DateTime.now().difference(f.purchaseDate).inDays;
      return sum + age;
    });
    avgAgeDays = (totalDays / flocks.length).round();
  }
  
  return FlockStats(
    totalFlocks: totalFlocks,
    totalChickens: totalChickens,
    layersCount: layers,
    broilersCount: broilers,
    kienyejiCount: kienyeji,
    avgAgeDays: avgAgeDays,
  );
});

// Stats model (removed eggsToday)
class FlockStats {
  final int totalFlocks;
  final int totalChickens;
  final int layersCount;
  final int broilersCount;
  final int kienyejiCount;
  final int avgAgeDays;

  FlockStats({
    required this.totalFlocks,
    required this.totalChickens,
    required this.layersCount,
    required this.broilersCount,
    required this.kienyejiCount,
    required this.avgAgeDays,
  });

  get avgFlockSize => null;
}
