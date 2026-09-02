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
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/presentation/providers/vaccine_provider.dart';
import 'package:leakuku/presentation/providers/stock_provider.dart';
import 'package:leakuku/presentation/providers/weekly_plan_provider.dart';
import 'package:leakuku/core/services/feeding_calculator.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/presentation/widgets/add_flock_dialog.dart';

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
            _buildDashboardHeader(user),
            const SizedBox(height: 14),
            _buildSectionTitle('Overview'),
            const SizedBox(height: 10),
            _buildFarmOverview(stats, flockState.flocks, nextVaccination),
            const SizedBox(height: 16),
            _buildSectionTitle('Today\'s Farm Plan'),
            const SizedBox(height: 10),
            _buildTodayFarmPlan(flockState.flocks, nextVaccination),
            const SizedBox(height: 16),
            _buildSectionTitle('Alerts'),
            const SizedBox(height: 10),
            _buildAlerts(flockState.flocks, nextVaccination),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(User? user) {
    final name = user?.name.trim().isNotEmpty == true ? user!.name : 'Farmer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, $name 👋',
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
    _UpcomingVaccination? nextVaccination,
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
        _overviewCard(
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
        _overviewCard(
          icon: FontAwesomeIcons.sackDollar,
          title: 'Farm Finances',
          value: 'Record',
          subtitle: 'Income and expenses',
          color: AppColors.harvestGold,
          onTap: () {
            Navigator.pushNamed(context, '/farm-finances');
          },
        ),
        _overviewCard(
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
        _overviewCard(
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

  Widget _overviewCard({
    required FaIconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(icon, color: color, size: 16),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: color,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            height: 1.25,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayFarmPlan(
      List<FlockModel> flocks, _UpcomingVaccination? nextVaccination) {
    final totalDailyFeed = _calculateDailyFeed(flocks);
    final planItems = <_PlanItem>[
      _PlanItem(
        icon: FontAwesomeIcons.bowlFood,
        title: 'Feed Birds',
        subtitle: flocks.isEmpty
            ? 'No data yet'
            : 'Prepare ${_formatFeed(totalDailyFeed)} today',
        color: AppColors.leakukuGreen,
        onTap: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
      _PlanItem(
        icon: FontAwesomeIcons.syringe,
        title: 'Vaccinate Birds',
        subtitle: nextVaccination == null
            ? 'No data yet'
            : '${nextVaccination.label} · ${nextVaccination.dueLabel}',
        color: AppColors.harvestGold,
        onTap: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
      _PlanItem(
        icon: FontAwesomeIcons.droplet,
        title: 'Check Water',
        subtitle:
            flocks.isEmpty ? 'No data yet' : 'Manual check for all drinkers',
        color: AppColors.informationBlue,
        onTap: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
      _PlanItem(
        icon: FontAwesomeIcons.penToSquare,
        title: 'Record Birds Lost',
        subtitle:
            flocks.isEmpty ? 'No data yet' : 'Update after morning rounds',
        color: AppColors.softGray,
        onTap: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
    ];

    return Column(
      children: planItems
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: FaIcon(item.icon, size: 16, color: item.color),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAlerts(
      List<FlockModel> flocks, _UpcomingVaccination? nextVaccination) {
    final stockItemsAsync = ref.watch(stockItemsProvider);
    final alerts = <_AlertItem>[];

    stockItemsAsync.whenData((items) {
      final lowStockCount = items.where((item) => item.isLowStock).length;
      if (lowStockCount > 0) {
        alerts.add(
          _AlertItem(
            icon: FontAwesomeIcons.boxOpen,
            title: 'Low Stock',
            subtitle: lowStockCount == 1
                ? '1 stock item is below minimum level.'
                : '$lowStockCount stock items are below minimum levels.',
            color: Colors.deepOrange,
            onTap: () => Navigator.pushNamed(context, '/stock'),
          ),
        );
      }
    });

    if (nextVaccination != null && nextVaccination.remainingDays <= 1) {
      alerts.add(
        _AlertItem(
          icon: FontAwesomeIcons.syringe,
          title: 'Vaccination Due',
          subtitle: '${nextVaccination.label} · ${nextVaccination.dueLabel}',
          color: AppColors.harvestGold,
          onTap: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
        ),
      );
    }

    final hasHighMortality = _hasHighMortalityAlert(flocks);
    if (hasHighMortality) {
      alerts.add(
        _AlertItem(
          icon: FontAwesomeIcons.heartPulse,
          title: 'High Mortality',
          subtitle:
              'One or more flocks have higher than planned mortality this week.',
          color: Colors.red,
          onTap: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
        ),
      );
    }

    if (alerts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.leakukuGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.circleCheck,
                    size: 16,
                    color: AppColors.leakukuGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No alerts today.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: alerts
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: entry.key == alerts.length - 1 ? 0 : 10),
              child: Card(
                child: InkWell(
                  onTap: entry.value.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: entry.value.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: FaIcon(
                              entry.value.icon,
                              size: 16,
                              color: entry.value.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  bool _hasHighMortalityAlert(List<FlockModel> flocks) {
    for (final flock in flocks) {
      final weeklyPlansAsync = ref.watch(weeklyPlansProvider(flock.id));
      final plans = weeklyPlansAsync.maybeWhen(
        data: (value) => value,
        orElse: () => const <WeeklyPlanModel>[],
      );

      final ageDays = DateTime.now().difference(flock.purchaseDate).inDays;
      final currentWeek = ageDays < 0 ? 1 : (ageDays ~/ 7) + 1;
      for (final plan in plans) {
        if (plan.weekNumber == currentWeek &&
            plan.actualMortalityPercent != null &&
            plan.actualMortalityPercent! > plan.plannedMortalityPercent) {
          return true;
        }
      }
    }

    return false;
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

  _UpcomingVaccination? _getNextVaccination(List<FlockModel> flocks) {
    final now = DateTime.now();
    _UpcomingVaccination? next;

    for (final flock in flocks) {
      final scheduleAsync = ref.watch(vaccineScheduleProvider(flock.id));
      scheduleAsync.whenData((vaccines) {
        for (final vaccine in vaccines) {
          final dueDate =
              flock.purchaseDate.add(Duration(days: vaccine.scheduleDayOffset));
          if (dueDate.isBefore(now)) {
            continue;
          }

          final candidate = _UpcomingVaccination(
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

class _PlanItem {
  final FaIconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PlanItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _UpcomingVaccination {
  final String label;
  final DateTime dueDate;

  const _UpcomingVaccination({
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

class _AlertItem {
  final FaIconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}


// UPDATED AddFlockDialog with edit & duplicate validation
