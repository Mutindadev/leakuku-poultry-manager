import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/user/presentation/provider/user_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(userProvider);
    final user = auth.userModel;
    final stats = ref.watch(flockStatsProvider);

    final name =
        user?.name.trim().isNotEmpty == true ? user!.name.trim() : 'Farmer';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(
            name: name,
            email: user?.email ?? '',
            role: user?.role ?? 'Farmer',
          ),
          const SizedBox(height: 24),
          Text(
            'Account details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.earthCharcoal,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _AccountDetails(
            email: user?.email,
            phone: user?.phonenumber,
            role: user?.role,
            createdAt: user?.createdAt,
          ),
          const SizedBox(height: 24),
          Text(
            'Farm overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.earthCharcoal,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.65,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _FarmStat(
                icon: FontAwesomeIcons.drumstickBite,
                label: 'Total flocks',
                value: '${stats.totalFlocks}',
                color: AppColors.leakukuGreen,
              ),
              _FarmStat(
                icon: FontAwesomeIcons.hashtag,
                label: 'Total chickens',
                value: '${stats.totalChickens}',
                color: AppColors.informationBlue,
              ),
            ],
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const FaIcon(
              FontAwesomeIcons.rightFromBracket,
              size: 16,
            ),
            label: const Text('Log out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.errorRed,
              side: BorderSide(
                color: AppColors.errorRed.withValues(alpha: 0.55),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(userProvider.notifier).signOut();

    if (context.mounted) {
      final auth = ref.read(userProvider);
      if (auth.authState == AuthenticationState.unauthenticated) {
        Navigator.of(context).pushReplacementNamed('/');
      } else if (auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage!)),
        );
      }
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? 'F' : name[0].toUpperCase();

    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.leakukuGreen,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.white,
              child: Text(
                initial,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.leakukuGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

class _AccountDetails extends StatelessWidget {
  const _AccountDetails({
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  final String? email;
  final String? phone;
  final String? role;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _displayValue(email),
          ),
          const Divider(height: 1, indent: 56),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _displayValue(phone),
          ),
          const Divider(height: 1, indent: 56),
          _DetailRow(
            icon: Icons.badge_outlined,
            label: 'Account type',
            value: _displayValue(role),
          ),
          const Divider(height: 1, indent: 56),
          _DetailRow(
            icon: Icons.calendar_month_outlined,
            label: 'Member since',
            value: _formatDate(createdAt),
          ),
        ],
      ),
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not added';
    return value.trim();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.leakukuGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.softGray,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.earthCharcoal,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmStat extends StatelessWidget {
  const _FarmStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final FaIconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            FaIcon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.softGray,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.earthCharcoal,
                          fontWeight: FontWeight.bold,
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
