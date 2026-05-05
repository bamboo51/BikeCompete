import 'package:flutter/material.dart';

import '../models/account_model.dart';
import '../services/api/api_service.dart';
import '../widgets/stat_card.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account'), centerTitle: true),
      body: FutureBuilder<AccountModel>(
        future: _apiService.fetchAccount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load account data.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No account data found.'));
          }

          final account = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                const CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.person, size: 48),
                ),

                const SizedBox(height: 16),

                Text(
                  account.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  account.department,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 32),

                StatCard(
                  label: 'Total Points',
                  value: '${account.stats.totalPoints} pt',
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Distance',
                        value:
                            '${account.stats.totalDistanceKm.toStringAsFixed(1)} km',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'CO2 Saved',
                        value:
                            '${account.stats.totalCo2SavedKg.toStringAsFixed(1)} kg',
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                StatCard(
                  label: 'Cycling Days',
                  value: '${account.stats.cyclingDays}',
                  color: Colors.orange,
                ),

                const SizedBox(height: 24),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('User ID'),
                        subtitle: Text(account.userId),
                      ),
                      if (account.badges.isNotEmpty) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.workspace_premium_outlined),
                          title: const Text('Badges'),
                          subtitle: Text(
                            account.badges
                                .map((badge) => badge.name)
                                .join(', '),
                          ),
                        ),
                      ],
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.apartment_outlined),
                        title: const Text('Department'),
                        subtitle: Text(account.department),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to settings page.
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Add logout logic.
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
