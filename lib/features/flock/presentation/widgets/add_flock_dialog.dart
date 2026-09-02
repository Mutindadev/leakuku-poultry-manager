import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/services/notification_service.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/domain/usecases/generate_vaccine_schedule.dart';
import 'package:leakuku/domain/usecases/generate_weekly_plan.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/presentation/providers/auth_provider.dart';
import 'package:leakuku/presentation/providers/breed_provider.dart';
import 'package:leakuku/presentation/providers/vaccine_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';

class AddFlockDialog extends StatefulWidget {
  final FlockModel? existing;

  const AddFlockDialog({super.key, this.existing});

  @override
  State<AddFlockDialog> createState() => _AddFlockDialogState();
}

class _AddFlockDialogState extends State<AddFlockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedBreed = 'Layers';
  DateTime _purchaseDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final flock = widget.existing;
    if (flock != null) {
      _nameController.text = flock.name;
      _quantityController.text = flock.quantity.toString();
      _selectedBreed = flock.breed;
      _purchaseDate = flock.purchaseDate;
      _notesController.text = flock.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final allFlocks = ref.watch(flockProvider).flocks;

        return AlertDialog(
          title: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.drumstickBite,
                color: AppColors.leakukuGreen,
              ),
              const SizedBox(width: 12),
              Text(widget.existing == null ? 'Add Birds' : 'Edit Batch'),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Batch Name',
                      prefixIcon: const FaIcon(FontAwesomeIcons.tag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a batch name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBreed,
                    decoration: InputDecoration(
                      labelText: 'Breed',
                      prefixIcon: const FaIcon(
                        FontAwesomeIcons.dna,
                        color: AppColors.leakukuGreen,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Layers',
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.egg,
                              size: 20,
                              color: AppColors.leakukuGreen,
                            ),
                            SizedBox(width: 12),
                            Text('Layers', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              '(Egg Production)',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Broilers',
                        child: Row(
                          children: [
                            Text('🍗', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 12),
                            Text('Broilers', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              '(Meat)',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Improved Kienyeji',
                        child: Row(
                          children: [
                            Text('🐔', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 12),
                            Text(
                              'Improved Kienyeji',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBreed = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Birds Received',
                      prefixIcon: const FaIcon(FontAwesomeIcons.hashtag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'How many birds are in this batch?',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the number of birds';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(
                      '${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}',
                      style: const TextStyle(
                        color: AppColors.leakukuGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: const FaIcon(
                      FontAwesomeIcons.calendar,
                      color: AppColors.leakukuGreen,
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectDate(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      prefixIcon: const FaIcon(FontAwesomeIcons.noteSticky),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Any extra information about this batch',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final authState = ref.read(authProvider);
                  final userId = authState.user?.id ?? '';
                  final nameLower = _nameController.text.trim().toLowerCase();

                  final duplicate = allFlocks.any(
                    (flock) =>
                        flock.userId == userId &&
                        flock.name.trim().toLowerCase() == nameLower &&
                        (widget.existing == null || flock.id != widget.existing!.id),
                  );

                  if (duplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('A batch with this name already exists'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final flock = FlockModel(
                    id: widget.existing?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text.trim(),
                    breed: _selectedBreed,
                    quantity: int.parse(_quantityController.text.trim()),
                    purchaseDate: _purchaseDate,
                    notes: _notesController.text.trim().isEmpty
                        ? null
                        : _notesController.text.trim(),
                    userId: userId,
                  );

                  if (widget.existing == null) {
                    await ref.read(flockProvider.notifier).addFlock(flock);

                    final breedIdMap = {
                      'Broilers': 'broilers',
                      'Layers': 'layers',
                      'Improved Kienyeji': 'kenbro',
                    };
                    final breedId = breedIdMap[flock.breed] ?? 'broilers';

                    try {
                      final breedDataSource = ref.read(breedDataSourceProvider);
                      final weeklyPlanDataSource = ref.read(weeklyPlanDataSourceProvider);
                      final generateWeeklyPlanUseCase = GenerateWeeklyPlanUseCase(
                        breedDataSource: breedDataSource,
                        weeklyPlanDataSource: weeklyPlanDataSource,
                      );

                      await generateWeeklyPlanUseCase.execute(
                        flockId: flock.id,
                        breedId: breedId,
                        flockQuantity: flock.quantity,
                        flockStartDate: flock.purchaseDate,
                      );

                      final vaccineDataSource = ref.read(vaccineDataSourceProvider);
                      final notificationService = NotificationService();
                      final generateVaccineScheduleUseCase =
                          GenerateVaccineScheduleUseCase(
                        vaccineDataSource: vaccineDataSource,
                        notificationService: notificationService,
                      );

                      await generateVaccineScheduleUseCase.execute(
                        flockId: flock.id,
                        breedId: breedId,
                        flockStartDate: flock.purchaseDate,
                      );
                    } catch (error) {
                      debugPrint('Error generating flock support data: $error');
                    }
                  } else {
                    await ref.read(flockProvider.notifier).updateFlock(flock);
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.circleCheck,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.existing == null
                                    ? 'Birds batch "${flock.name}" added.'
                                    : 'Batch "${flock.name}" updated.',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.leakukuGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              icon: FaIcon(
                widget.existing == null
                    ? FontAwesomeIcons.plus
                    : FontAwesomeIcons.floppyDisk,
              ),
              label: Text(widget.existing == null ? 'Add Birds' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.leakukuGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}