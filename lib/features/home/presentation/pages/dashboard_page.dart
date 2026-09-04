import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/services/feeding_calculator.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/pages/flock_page.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/flock/presentation/widgets/add_flock_dialog.dart';
import 'package:leakuku/features/home/presentation/widgets/alert_card.dart';
import 'package:leakuku/features/home/presentation/widgets/farm_plan.dart';
import 'package:leakuku/features/home/presentation/widgets/overview_card.dart';
import 'package:leakuku/features/profile/presentation/profile_page.dart';
import 'package:leakuku/features/progress/presentation/pages/progress_page.dart';
import 'package:leakuku/features/reports/presentation/reports_page.dart';
import 'package:leakuku/presentation/providers/auth_provider.dart';
import 'package:leakuku/presentation/providers/vaccine_provider.dart';

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
    final flockState = ref.watch(flockProvider);
    final stats = ref.watch(flockStatsProvider);
    final nextVaccination = _getNextVaccination(flockState.flocks);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildDashboardHeader(user),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, ${user?.name.trim().isNotEmpty == true ? user!.name : 'Farmer'} 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🌱 Healthy habits build healthy birds.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildSectionTitle('Overview'),

            const SizedBox(height: 10),

            _buildFarmOverview(stats, flockState.flocks, nextVaccination),

            const SizedBox(height: 16),

            _buildSectionTitle('Today\'s Farm Plan'),

            const SizedBox(height: 10),

            FarmPlan(
              selectedIndex: _selectedIndex,
              flocks: flockState.flocks,
              nextVaccination: nextVaccination,
              totalaDailyFeed: _calculateDailyFeed(flockState.flocks),
              onIndexChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildSectionTitle('Alerts'),

            const SizedBox(height: 10),

            AlertCard(
              selectedIndex: _selectedIndex,
              flocks: flockState.flocks,
              nextVaccination: nextVaccination,
              onIndexChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildFarmOverview(
    FlockStats stats,
    List<FlockModel> flocks,
    UpcomingVaccination? nextVaccination,
  ) {
    final totalDailyFeed = _calculateDailyFeed(flocks);

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.18,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        OverviewCard(
          icon: FontAwesomeIcons.drumstickBite,
          title: 'Birds Alive',
          value: '${stats.totalChickens}',
          subtitle: stats.totalFlocks == 0
              ? 'No data yet'
              : '${stats.totalFlocks} active flock${stats.totalFlocks == 1 ? '' : 's'}',
          color: AppColors.leakukuGreen,
          onTap: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
        ),
        OverviewCard(
          icon: FontAwesomeIcons.sackDollar,
          title: 'Farm Finances',
          value: 'Record',
          subtitle: 'Income and expenses',
          color: AppColors.harvestGold,
          onTap: () {
            Navigator.pushNamed(context, '/farm-finances');
          },
        ),
        OverviewCard(
          icon: FontAwesomeIcons.bowlFood,
          title: "Today's Feed",
          value: flocks.isEmpty ? '—' : _formatFeed(totalDailyFeed),
          subtitle: flocks.isEmpty ? 'No data yet' : 'Recommended for today',
          color: AppColors.informationBlue,
          onTap: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
        ),
        OverviewCard(
          icon: FontAwesomeIcons.boxOpen,
          title: 'Feed Stock',
          value: '—',
          subtitle: 'No data yet',
          color: AppColors.softGray,
          onTap: () => Navigator.pushNamed(context, '/stock'),
        ),
      ],
    );
  }

  double _calculateDailyFeed(List<FlockModel> flocks) {
    double totalGrams = 0;

    for (final flock in flocks) {
      final ageDays = DateTime.now().difference(flock.purchaseDate).inDays;
      final perBird = FeedingCalculator.getDailyFoodGrams(flock.breed, ageDays);
      totalGrams += perBird * flock.quantity;
    }

    return totalGrams;
  }

  String _formatFeed(double grams) {
    if (grams >= 1000) {
      return '${(grams / 1000).toStringAsFixed(1)} kg';
    }
    return '${grams.toStringAsFixed(0)} g';
  }

  UpcomingVaccination? _getNextVaccination(List<FlockModel> flocks) {
    final now = DateTime.now();
    UpcomingVaccination? next;

    for (final flock in flocks) {
      final scheduleAsync = ref.watch(vaccineScheduleProvider(flock.id));
      scheduleAsync.whenData((vaccines) {
        for (final vaccine in vaccines) {
          final dueDate =
              flock.purchaseDate.add(Duration(days: vaccine.scheduleDayOffset));
          if (dueDate.isBefore(now)) {
            continue;
          }

          final candidate = UpcomingVaccination(
            label: vaccine.vaccineName,
            dueDate: dueDate,
          );

          if (next == null || dueDate.isBefore(next!.dueDate)) {
            next = candidate;
          }
        }
      });
    }

    return next;
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
      const FlockPage(embedded: true),
      const ProgressPage(),
      const ReportsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell),
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
        selectedItemColor: AppColors.leakukuGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.drumstickBite),
            label: 'Birds',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.chartLine),
            label: 'Daily Records',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.fileLines),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                _showAddFlockDialog(context);
              },
              icon: const FaIcon(FontAwesomeIcons.plus),
              label: const Text('Add Birds'),
              backgroundColor: AppColors.leakukuGreen,
            )
          : null,
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Birds';
      case 2:
        return 'Daily Records';
      case 3:
        return 'Reports & Analytics';
      case 4:
        return 'Profile';
      default:
        return 'LeaKuku';
    }
  }
}

class UpcomingVaccination {
  final String label;
  final DateTime dueDate;

  const UpcomingVaccination({
    required this.label,
    required this.dueDate,
  });

  String get dueLabel {
    final remainingDays = this.remainingDays;
    if (remainingDays <= 0) {
      return 'Due today';
    }
    if (remainingDays == 1) {
      return 'Due tomorrow';
    }
    return 'Due in $remainingDays days';
  }

  int get remainingDays => dueDate.difference(DateTime.now()).inDays;
}

// UPDATED AddFlockDialog with edit & duplicate validation
