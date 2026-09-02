import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/batch_details_page.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/flock/presentation/widgets/add_flock_dialog.dart';

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

  Color _getBreedColor(String breed) {
    switch (breed) {
      case 'Layers':
        return AppColors.leakukuGreen;
      case 'Broilers':
        return Colors.orange;
      case 'Improved Kienyeji':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _openAddBirdsDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddFlockDialog(),
    );
  }

  void _openBatchDetails(FlockModel flock) {
    ref.read(selectedFlockIdProvider.notifier).state = flock.id;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BatchDetailsPage(flock: flock),
      ),
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
          _BirdsLoadingCard(),
          SizedBox(height: 12),
          _BirdsLoadingCard(),
          SizedBox(height: 12),
          _BirdsLoadingCard(),
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
        return _buildBirdCard(context, flock);
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

  Widget _buildBirdCard(BuildContext context, FlockModel flock) {
    final ageDays = DateTime.now().difference(flock.purchaseDate).inDays;
    final stage = _getStage(ageDays);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _getBreedColor(flock.breed).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(child: _getBreedIcon(flock.breed)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flock.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.earthCharcoal,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getBreedColor(flock.breed)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          flock.breed,
                          style: TextStyle(
                            color: _getBreedColor(flock.breed),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      showDialog(
                        context: context,
                        builder: (context) => AddFlockDialog(existing: flock),
                      );
                      return;
                    }

                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Batch'),
                          content: Text(
                            'Are you sure you want to delete "${flock.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await ref
                            .read(flockProvider.notifier)
                            .deleteFlock(flock.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${flock.name} deleted'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    context,
                    label: 'Birds Alive',
                    value: '${flock.quantity}',
                    icon: FontAwesomeIcons.heartPulse,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoTile(
                    context,
                    label: 'Age',
                    value: _calculateAge(flock.purchaseDate),
                    icon: FontAwesomeIcons.clockRotateLeft,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoTile(
                    context,
                    label: 'Current Stage',
                    value: stage,
                    icon: FontAwesomeIcons.seedling,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openBatchDetails(flock),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.leakukuGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAge(DateTime purchaseDate) {
    final now = DateTime.now();
    final difference = now.difference(purchaseDate);

    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    }
  }

  String _getStage(int ageDays) {
    if (ageDays <= 21) {
      return 'Brooding';
    }
    if (ageDays <= 140) {
      return 'Growing';
    }
    return 'Production';
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required FaIconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.farmCream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 15, color: AppColors.leakukuGreen),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.earthCharcoal,
                ),
          ),
        ],
      ),
    );
  }

  Widget _getBreedIcon(String breed) {
    switch (breed) {
      case 'Layers':
        return const FaIcon(FontAwesomeIcons.egg,
            color: AppColors.leakukuGreen, size: 28);
      case 'Broilers':
        return const Text('🍗', style: TextStyle(fontSize: 28));
      case 'Improved Kienyeji':
        return const Text('🐔', style: TextStyle(fontSize: 28));
      default:
        return const FaIcon(FontAwesomeIcons.question,
            color: Colors.grey, size: 28);
    }
  }
}

class _BirdsLoadingCard extends StatelessWidget {
  const _BirdsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 12,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 10),
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
