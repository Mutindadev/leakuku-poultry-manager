import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/domain/entities/user.dart';
import 'package:leakuku/presentation/providers/auth_provider.dart';
import 'package:leakuku/features/flock/presentation/flock_page.dart';
import 'package:leakuku/features/progress/presentation/progress_page.dart';
import 'package:leakuku/features/reports/presentation/reports_page.dart';
import 'package:leakuku/features/profile/presentation/profile_page.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load flocks after widget mounts
    Future.microtask(() {
      ref.read(flockProvider.notifier).loadFlocks();
    });
  }

  Widget _buildHomePage() {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(user),
          _buildQuickStats(),
          _buildRecentActivity(),
          _buildManageFlocksSection(), // NEW
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Reduced from 24
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF4CAF50).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            user?.name ?? 'Farmer',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              user?.role ?? 'Farmer',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final flockState = ref.watch(flockProvider);

    if (flockState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    if (flockState.error != null && flockState.error!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(FontAwesomeIcons.triangleExclamation,
                    color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to load flock stats: ${flockState.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(flockProvider.notifier).loadFlocks(),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      );
    }

    // Use memoized stats provider instead of recalculating
    final stats = ref.watch(flockStatsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: FontAwesomeIcons.drumstickBite,
                  title: 'Total Flocks',
                  value: '${stats.totalFlocks}',
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: FontAwesomeIcons.hashtag,
                  title: 'Chickens',
                  value: '${stats.totalChickens}',
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: FontAwesomeIcons.calendar,
                  title: 'Avg Age',
                  value: '${stats.avgAgeDays} days', // FIX: Changed from avgFlockSize
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: FontAwesomeIcons.chartLine,
                  title: 'Growth',
                  value: 'Active', // Placeholder
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    FontAwesomeIcons.clock,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No activity yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track feeding, weighing, and health checks here',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageFlocksSection() {
    final flockState = ref.watch(flockProvider);
    final flocks = flockState.flocks;
    if (flockState.isLoading) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Flocks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (flocks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.drumstickBite, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No flocks added yet. Use "Add Flock" to create one.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...flocks.map((f) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                      child: f.breed.toLowerCase() == 'layers'
                          ? const Icon(FontAwesomeIcons.egg, color: Color(0xFF4CAF50), size: 18)
                          : f.breed.toLowerCase() == 'broilers'
                              ? const Text('🍗', style: TextStyle(fontSize: 20)) // Chicken wing emoji
                              : const Text('🐔', style: TextStyle(fontSize: 20)), // Chicken emoji for Kienyeji
                    ),
                    title: Text(f.name),
                    subtitle: Text('${f.breed} • ${f.quantity} chickens'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _showAddFlockDialog(context, existing: f);
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Delete Flock'),
                              content: Text('Are you sure you want to delete "${f.name}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(flockProvider.notifier).deleteFlock(f.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Flock "${f.name}" deleted'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (c) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _showAddFlockDialog(BuildContext context, {FlockModel? existing}) {
    showDialog(
      context: context,
      builder: (context) => AddFlockDialog(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const FlockPage(),
      const ProgressPage(),     
      const ReportsPage(),     
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.bell),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.drumstickBite),
            label: 'Flocks',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.chartLine),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.fileLines),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                _showAddFlockDialog(context);
              },
              icon: const Icon(FontAwesomeIcons.plus),
              label: const Text('Add Flock'),
              backgroundColor: const Color(0xFF4CAF50),
            )
          : null,
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'My Flocks';
      case 2:
        return 'Progress Tracking';
      case 3:
        return 'Reports & Analytics';
      case 4:
        return 'Profile';
      default:
        return 'LeaKuku';
    }
  }
}

// UPDATED AddFlockDialog with edit & duplicate validation
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
    final f = widget.existing;
    if (f != null) {
      _nameController.text = f.name;
      _quantityController.text = f.quantity.toString();
      _selectedBreed = f.breed;
      _purchaseDate = f.purchaseDate;
      _notesController.text = f.notes ?? '';
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
              const Icon(FontAwesomeIcons.drumstickBite, color: Color(0xFF4CAF50)),
              const SizedBox(width: 12),
              Text(widget.existing == null ? 'Add New Flock' : 'Edit Flock'),
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
                      labelText: 'Flock Name',
                      prefixIcon: const Icon(FontAwesomeIcons.tag),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter flock name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBreed,
                    decoration: InputDecoration(
                      labelText: 'Breed Type',
                      prefixIcon: const Icon(FontAwesomeIcons.dna, color: Color(0xFF4CAF50)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Layers',
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.egg, size: 20, color: Color(0xFF4CAF50)),
                            SizedBox(width: 12),
                            Text('Layers', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text('(Egg Production)', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                            Text('(Meat)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Improved Kienyeji',
                        child: Row(
                          children: [
                            Text('🐔', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 12),
                            Text('Improved Kienyeji', style: TextStyle(fontSize: 16)),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Number of Chickens',
                      prefixIcon: const Icon(FontAwesomeIcons.hashtag),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      helperText: 'How many chickens in this flock?',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Purchase Date'),
                    subtitle: Text(
                      '${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}',
                      style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
                    ),
                    leading: const Icon(FontAwesomeIcons.calendar, color: Color(0xFF4CAF50)),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectDate(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      prefixIcon: const Icon(FontAwesomeIcons.noteSticky),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      helperText: 'Any additional information',
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
                  // Duplicate name check (case-insensitive) per user
                  final authState = ref.read(authProvider);
                  final userId = authState.user?.id ?? '';
                  final nameLower = _nameController.text.trim().toLowerCase();
                  final duplicate = allFlocks.any((f) =>
                      f.userId == userId &&
                      f.name.trim().toLowerCase() == nameLower &&
                      (widget.existing == null || f.id != widget.existing!.id));
                  if (duplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('A flock with this name already exists'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final flock = FlockModel(
                    id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text.trim(),
                    breed: _selectedBreed,
                    quantity: int.parse(_quantityController.text.trim()),
                    purchaseDate: _purchaseDate,
                    notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                    userId: userId,
                  );

                  if (widget.existing == null) {
                    await ref.read(flockProvider.notifier).addFlock(flock);
                  } else {
                    await ref.read(flockProvider.notifier).updateFlock(flock);
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(FontAwesomeIcons.checkCircle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.existing == null
                                    ? 'Flock "${flock.name}" added!'
                                    : 'Flock "${flock.name}" updated!',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              icon: Icon(widget.existing == null ? FontAwesomeIcons.plus : FontAwesomeIcons.floppyDisk),
              label: Text(widget.existing == null ? 'Add Flock' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      },
    );
  }
}
