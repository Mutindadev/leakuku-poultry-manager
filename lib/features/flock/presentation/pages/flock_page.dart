import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/flock/presentation/widgets/add_flock_dialog.dart';
import 'package:leakuku/features/flock/presentation/widgets/bird_card.dart';
import 'package:leakuku/features/flock/presentation/widgets/birds_loading_card.dart';

class FlockPage extends ConsumerStatefulWidget {
  final bool embedded;

  const FlockPage({super.key, this.embedded = false});

  @override
  ConsumerState<FlockPage> createState() => _FlockPageState();
}

class _FlockPageState extends ConsumerState<FlockPage> {
  @override
  void initState() {
    super.initState();
    // Load flocks when page initializes
    Future.microtask(() => ref.read(flockProvider.notifier).loadFlocks());
  }

  void _openAddBirdsDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddFlockDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flockState = ref.watch(flockProvider);
    final flocks = flockState.flocks;

    final birdsBody = Container(
      color: AppColors.farmCream,
      child: RefreshIndicator(
        color: AppColors.leakukuGreen,
        onRefresh: () => ref.read(flockProvider.notifier).loadFlocks(),
        child: _buildBody(context, flockState, flocks),
      ),
    );

    if (widget.embedded) {
      return birdsBody;
    }

    return Scaffold(
      backgroundColor: AppColors.farmCream,
      appBar: AppBar(
        title: const Text('Birds'),
        actions: [
          TextButton.icon(
            onPressed: _openAddBirdsDialog,
            icon: const Icon(Icons.add, color: AppColors.leakukuGreen),
            label: const Text(
              'Add Birds',
              style: TextStyle(color: AppColors.leakukuGreen),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: birdsBody,
    );
  }

  Widget _buildBody(
    BuildContext context,
    FlockState flockState,
    List<FlockModel> flocks,
  ) {
    if (flockState.isLoading) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: const [
          BirdsLoadingCard(),
          SizedBox(height: 12),
          BirdsLoadingCard(),
          SizedBox(height: 12),
          BirdsLoadingCard(),
          SizedBox(height: 12),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 12),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.leakukuGreen,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (flockState.error != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.errorRed),
                  const SizedBox(height: 16),
                  Text(
                    'We could not load your birds right now.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    flockState.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(flockProvider.notifier).loadFlocks(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.leakukuGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (flocks.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          _buildIntroCard(context),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.leakukuGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.drumstickBite,
                        size: 36,
                        color: AppColors.leakukuGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No birds added yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.earthCharcoal,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first batch to start tracking your birds in one place.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _openAddBirdsDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Birds'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.leakukuGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      itemCount: flocks.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildIntroCard(context);
        }

        final flock = flocks[index - 1];
        return BirdCard(flock: flock);
      },
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.drumstickBite,
                  color: AppColors.leakukuGreen,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your bird batches',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.earthCharcoal,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'See each batch at a glance and open details when you need to manage it.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
