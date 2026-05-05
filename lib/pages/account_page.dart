import 'package:flutter/material.dart';

import '../models/account_model.dart';
import '../services/api/api_service.dart';
import '../widgets/stat_card.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static final ApiService _apiService = ApiService();
  static const AccountModel _dummyAccount = AccountModel(
    userId: 'worker_003',
    name: 'Phongwit',
    department: 'Frontend',
    stats: UserStats(
      totalPoints: 1950,
      totalDistanceKm: 96.4,
      totalCo2SavedKg: 19.3,
      cyclingDays: 14,
    ),
    badges: [
      BadgeModel(id: 'badge_001', name: '7-Day Streak'),
      BadgeModel(id: 'badge_002', name: '100 km Rider'),
      BadgeModel(id: 'badge_003', name: 'CO2 Saver'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impact Profile')),
      body: FutureBuilder<AccountModel>(
        future: _apiService.fetchAccount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _AccountContent(
              account: _dummyAccount,
              isDummy: true,
              loadError: snapshot.error,
            );
          }

          if (!snapshot.hasData) {
            return const _AccountContent(account: _dummyAccount, isDummy: true);
          }

          return _AccountContent(account: snapshot.data!);
        },
      ),
    );
  }
}

class _AccountContent extends StatelessWidget {
  final AccountModel account;
  final bool isDummy;
  final Object? loadError;

  const _AccountContent({
    required this.account,
    this.isDummy = false,
    this.loadError,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(Icons.eco, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              account.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          if (isDummy) ...[
                            const SizedBox(width: 8),
                            const _DummyTag(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.department,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isDummy) ...[
          const SizedBox(height: 10),
          _FallbackNotice(loadError: loadError),
        ],
        const SizedBox(height: 16),
        StatCard(
          label: 'Total Points',
          value: '${account.stats.totalPoints} pt',
          color: colorScheme.primary,
          icon: Icons.stars_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Distance',
                value: '${account.stats.totalDistanceKm.toStringAsFixed(1)} km',
                color: colorScheme.secondary,
                icon: Icons.directions_bike_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'CO2 Saved',
                value: '${account.stats.totalCo2SavedKg.toStringAsFixed(1)} kg',
                color: const Color(0xFF0277BD),
                icon: Icons.air_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatCard(
          label: 'Cycling Days',
          value: '${account.stats.cyclingDays}',
          color: colorScheme.tertiary,
          icon: Icons.calendar_month_outlined,
        ),
        const SizedBox(height: 24),
        Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Card(
          color: colorScheme.surfaceContainerLowest,
          child: Column(
            children: [
              _ProfileTile(
                icon: Icons.badge_outlined,
                iconColor: colorScheme.primary,
                title: 'User ID',
                subtitle: account.userId,
              ),
              if (account.badges.isNotEmpty) ...[
                const Divider(height: 1),
                _ProfileTile(
                  icon: Icons.workspace_premium_outlined,
                  iconColor: colorScheme.tertiary,
                  title: 'Badges',
                  subtitle: account.badges
                      .map((badge) => badge.name)
                      .join(', '),
                ),
              ],
              const Divider(height: 1),
              _ProfileTile(
                icon: Icons.apartment_outlined,
                iconColor: colorScheme.secondary,
                title: 'Department',
                subtitle: account.department,
              ),
              const Divider(height: 1),
              _ProfileTile(
                icon: Icons.settings_outlined,
                iconColor: colorScheme.onSurfaceVariant,
                title: 'Settings',
                subtitle: 'Preferences and account options',
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DummyTag extends StatelessWidget {
  const _DummyTag();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Dummy',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onTertiary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FallbackNotice extends StatelessWidget {
  final Object? loadError;

  const _FallbackNotice({this.loadError});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: colorScheme.onTertiaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loadError == null
                    ? 'Showing dummy account data.'
                    : 'Showing dummy account data because the account API could not load.\n$loadError',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}
