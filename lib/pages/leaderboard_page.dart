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
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Carbon Ride Challenge',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Compete by cycling, saving CO₂, and earning points.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

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
              setState(() {
                showWorkers = value.first;
              });
            },
          ),

          const SizedBox(height: 24),

          TopThreeSection(users: topThree),

          const SizedBox(height: 24),

          Text(
            showWorkers ? 'Worker Ranking' : 'Department Ranking',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

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
        ],
      ),
    );
  }
}

class TopThreeSection extends StatelessWidget {
  final List<LeaderboardUser> users;

  const TopThreeSection({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    if (users.length < 3) {
      return const SizedBox.shrink();
    }

    final second = users[1];
    final first = users[0];
    final third = users[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: PodiumCard(
            user: second,
            height: 150,
            icon: Icons.looks_two,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PodiumCard(
            user: first,
            height: 190,
            icon: Icons.emoji_events,
            isChampion: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PodiumCard(
            user: third,
            height: 130,
            icon: Icons.looks_3,
          ),
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
      elevation: isChampion ? 2 : 0,
      color: isChampion
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isChampion ? 36 : 30,
                color: isChampion
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                '#${user.rank}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${user.points} pts',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isChampion
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: _rankBackgroundColor(context),
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: rank <= 3
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '$subtitle • ${distanceKm.toStringAsFixed(1)} km • '
                '${co2SavedKg.toStringAsFixed(1)} kg CO₂ saved',
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$points',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'pts',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rankBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (rank <= 3) {
      return colorScheme.primaryContainer;
    }

    return colorScheme.surfaceContainerHighest;
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