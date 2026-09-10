import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/progress/domain/service/progress_service.dart';

class HeaderCard extends ConsumerStatefulWidget {
  final FlockModel flock;
  final int ageDays;
  final String stage;
  final int completedTasks;
  final int totalTasks;
  final List<FlockModel> allFlocks;

  const HeaderCard({
    super.key,
    required this.flock,
    required this.ageDays,
    required this.stage,
    required this.completedTasks,
    required this.totalTasks,
    required this.allFlocks,
  });

  @override
  ConsumerState<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends ConsumerState<HeaderCard> {
  @override
  Widget build(BuildContext context) {
    const progressService = ProgressService();

    final stage = progressService.getStage(widget.ageDays);
    final progressLabel =
        '${widget.completedTasks} of ${widget.totalTasks} tasks completed';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.allFlocks.length > 1) ...[
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                key: ValueKey(widget.flock.id),
                initialValue: widget.flock.id,
                decoration: InputDecoration(
                  labelText: 'Current batch',
                  filled: true,
                  fillColor: AppColors.farmCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: widget.allFlocks
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  ref.read(selectedFlockIdProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 18),
            ] else ...[
              const SizedBox(height: 4),
            ],
            Text(
              widget.flock.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthCharcoal,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progressService.formatAgeLabel(widget.ageDays)} • $stage Stage',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${progressService.formatWholeNumber(widget.flock.quantity)} Birds Alive',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthCharcoal,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.farmCream,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.listCheck,
                        color: AppColors.leakukuGreen,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Progress',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          progressLabel,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: widget.totalTasks == 0
                              ? 0
                              : widget.completedTasks / widget.totalTasks,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.leakukuGreen,
                          strokeWidth: 5,
                        ),
                        Center(
                          child: Text(
                            '${widget.completedTasks}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
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
