import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/pages/batch_details_page.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/flock/presentation/widgets/add_flock_dialog.dart';

class BirdCard extends ConsumerStatefulWidget {
  final FlockModel flock;

  const BirdCard({super.key, required this.flock});

  @override
  ConsumerState<BirdCard> createState() => _BirdCardState();
}

class _BirdCardState extends ConsumerState<BirdCard> {
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

  void _openBatchDetails(FlockModel flock) {
    ref.read(selectedFlockIdProvider.notifier).state = flock.id;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BatchDetailsPage(flock: flock),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final ageDays = DateTime.now().difference(widget.flock.purchaseDate).inDays;
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
                    color: _getBreedColor(widget.flock.breed)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(child: _getBreedIcon(widget.flock.breed)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.flock.name,
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
                          color: _getBreedColor(widget.flock.breed)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          widget.flock.breed,
                          style: TextStyle(
                            color: _getBreedColor(widget.flock.breed),
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
                        builder: (context) =>
                            AddFlockDialog(existing: widget.flock),
                      );
                      return;
                    }

                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Batch'),
                          content: Text(
                            'Are you sure you want to delete "${widget.flock.name}"?',
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
                            .deleteFlock(widget.flock.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${widget.flock.name} deleted'),
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
                    value: '${widget.flock.quantity}',
                    icon: FontAwesomeIcons.heartPulse,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoTile(
                    context,
                    label: 'Age',
                    value: _calculateAge(widget.flock.purchaseDate),
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
                onPressed: () => _openBatchDetails(widget.flock),
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
}
