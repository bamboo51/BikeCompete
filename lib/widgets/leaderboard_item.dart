import 'package:flutter/material.dart';

import '../models/leaderboard_user_model.dart';

class LeaderboardItem extends StatelessWidget {
  final LeaderboardUserModel user;

  const LeaderboardItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('#${user.rank}')),
        title: Text(user.name),
        trailing: Text(
          '${user.points} pt',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
