import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool showWorkers = true;

  final List<LeaderboardUser> workers = const [
    LeaderboardUser(
      rank: 1,
      name: 'Tanaka',
      department: 'Production',
      points: 2400,
      co2SavedKg: 24.1,
      distanceKm: 120.5,
    ),
    LeaderboardUser(
      rank: 2,
      name: 'Sato',
      department: 'Engineering',
      points: 2150,
      co2SavedKg: 21.2,
      distanceKm: 106.2,
    ),
    LeaderboardUser(
      rank: 3,
      name: 'Phongwit',
      department: 'Frontend',
      points: 1950,
      co2SavedKg: 19.3,
      distanceKm: 96.4,
    ),
    LeaderboardUser(
      rank: 4,
      name: 'Yamada',
      department: 'Office',
      points: 1720,
      co2SavedKg: 16.8,
      distanceKm: 84.1,
    ),
    LeaderboardUser(
      rank: 5,
      name: 'Kobayashi',
      department: 'Maintenance',
      points: 1490,
      co2SavedKg: 14.7,
      distanceKm: 73.5,
    ),
  ];

  final List<LeaderboardDepartment> departments = const [
    LeaderboardDepartment(
      rank: 1,
      name: 'Production',
      points: 9800,
      co2SavedKg: 102.4,
      distanceKm: 512.0,
    ),
    LeaderboardDepartment(
      rank: 2,
      name: 'Engineering',
      points: 8600,
      co2SavedKg: 89.1,
      distanceKm: 445.5,
    ),
    LeaderboardDepartment(
      rank: 3,
      name: 'Office',
      points: 7300,
      co2SavedKg: 76.8,
      distanceKm: 384.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topThree = showWorkers
        ? workers.take(3).toList()
        : departments
              .take(3)
              .map(
                (department) => LeaderboardUser(
                  rank: department.rank,
                  name: department.name,
                  department: 'Department',
                  points: department.points,
                  co2SavedKg: department.co2SavedKg,
                  distanceKm: department.distanceKm,
                ),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _LeaderboardSummary(
            title: showWorkers ? 'Top rider' : 'Top department',
            leaderName: topThree.first.name,
            leaderPoints: topThree.first.points,
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('Workers'),
                icon: Icon(Icons.person_outline),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('Departments'),
                icon: Icon(Icons.groups_outlined),
              ),
            ],
            selected: {showWorkers},
            onSelectionChanged: (value) {
              setState(() => showWorkers = value.first);
            },
          ),
          const SizedBox(height: 20),
          TopThreeSection(users: topThree),
          const SizedBox(height: 24),
          _SectionTitle(showWorkers ? 'Worker ranking' : 'Department ranking'),
          const SizedBox(height: 10),
          if (showWorkers)
            ...workers.map(
              (user) => LeaderboardItem(
                rank: user.rank,
                name: user.name,
                subtitle: user.department,
                points: user.points,
                co2SavedKg: user.co2SavedKg,
                distanceKm: user.distanceKm,
              ),
            )
          else
            ...departments.map(
              (department) => LeaderboardItem(
                rank: department.rank,
                name: department.name,
                subtitle: 'Department total',
                points: department.points,
                co2SavedKg: department.co2SavedKg,
                distanceKm: department.distanceKm,
              ),
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}

class _LeaderboardSummary extends StatelessWidget {
  final String title;
  final String leaderName;
  final int leaderPoints;

  const _LeaderboardSummary({
    required this.title,
    required this.leaderName,
    required this.leaderPoints,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.emoji_events),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    leaderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$leaderPoints',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class TopThreeSection extends StatelessWidget {
  final List<LeaderboardUser> users;

  const TopThreeSection({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.length < 3) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: PodiumCard(user: users[1], height: 140, icon: Icons.looks_two),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PodiumCard(
            user: users[0],
            height: 172,
            icon: Icons.emoji_events,
            isChampion: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PodiumCard(user: users[2], height: 128, icon: Icons.looks_3),
        ),
      ],
    );
  }
}

class PodiumCard extends StatelessWidget {
  final LeaderboardUser user;
  final double height;
  final IconData icon;
  final bool isChampion;

  const PodiumCard({
    super.key,
    required this.user,
    required this.height,
    required this.icon,
    this.isChampion = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: isChampion
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainer,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isChampion ? colorScheme.primary : colorScheme.secondary,
                size: isChampion ? 34 : 28,
              ),
              const SizedBox(height: 8),
              Text(
                '#${user.rank}',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                user.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '${user.points} pts',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final String subtitle;
  final int points;
  final double co2SavedKg;
  final double distanceKm;

  const LeaderboardItem({
    super.key,
    required this.rank,
    required this.name,
    required this.subtitle,
    required this.points,
    required this.co2SavedKg,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: colorScheme.surfaceContainerLowest,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: rank <= 3
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          foregroundColor: rank <= 3
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          child: Text(
            '$rank',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '$subtitle\n${distanceKm.toStringAsFixed(1)} km  |  '
            '${co2SavedKg.toStringAsFixed(1)} kg CO2',
            maxLines: 2,
          ),
        ),
        trailing: SizedBox(
          width: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$points',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'pts',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaderboardUser {
  final int rank;
  final String name;
  final String department;
  final int points;
  final double co2SavedKg;
  final double distanceKm;

  const LeaderboardUser({
    required this.rank,
    required this.name,
    required this.department,
    required this.points,
    required this.co2SavedKg,
    required this.distanceKm,
  });
}

class LeaderboardDepartment {
  final int rank;
  final String name;
  final int points;
  final double co2SavedKg;
  final double distanceKm;

  const LeaderboardDepartment({
    required this.rank,
    required this.name,
    required this.points,
    required this.co2SavedKg,
    required this.distanceKm,
  });
}
