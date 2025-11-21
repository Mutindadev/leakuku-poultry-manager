import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';

class FlockPage extends ConsumerStatefulWidget {
  const FlockPage({super.key});

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
        return const Color(0xFF4CAF50);
      case 'Broilers':
        return Colors.orange;
      case 'Improved Kienyeji':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    final flockState = ref.watch(flockProvider);
    final flocks = flockState.flocks;

    if (flockState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
        ),
      );
    }

    if (flockState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${flockState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(flockProvider.notifier).loadFlocks(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (flocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.drumstickBite,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No flocks yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first flock',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    // Use ListView.builder for lazy loading (performance for large lists)
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flocks.length,
      itemBuilder: (context, index) {
        final flock = flocks[index];
        final age = _calculateAge(flock.purchaseDate);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('View ${flock.name} details')),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getBreedColor(flock.breed).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _getBreedIcon(flock.breed),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flock.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getBreedColor(flock.breed).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
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
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
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
                        onSelected: (value) async {
                          if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Flock'),
                                content: Text('Are you sure you want to delete "${flock.name}"?'),
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
                              await ref.read(flockProvider.notifier).deleteFlock(flock.id);
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
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoChip(
                        context,
                        icon: FontAwesomeIcons.hashtag,
                        label: 'Chickens',
                        value: '${flock.quantity}',
                      ),
                      _buildInfoChip(
                        context,
                        icon: FontAwesomeIcons.clockRotateLeft,
                        label: 'Age',
                        value: age,
                      ),
                      _buildInfoChip(
                        context,
                        icon: FontAwesomeIcons.heartPulse,
                        label: 'Health',
                        value: '95%',
                      ),
                    ],
                  ),
                  if (flock.notes != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Notes: ${flock.notes}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _calculateAge(DateTime purchaseDate) {
    final now = DateTime.now();
    final difference = now.difference(purchaseDate);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    }
  }

  Widget _buildInfoChip(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _getBreedIcon(String breed) {
    switch (breed) {
      case 'Layers':
        return const Icon(FontAwesomeIcons.egg, color: Color(0xFF4CAF50), size: 28);
      case 'Broilers':
        return const Text('🍗', style: TextStyle(fontSize: 28));
      case 'Improved Kienyeji':
        return const Text('🐔', style: TextStyle(fontSize: 28));
      default:
        return const Icon(FontAwesomeIcons.question, color: Colors.grey, size: 28);
    }
  }
}
