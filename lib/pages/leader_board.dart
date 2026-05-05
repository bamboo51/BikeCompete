import 'package:flutter/material.dart';

class LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final double co2SavedKg;
  final double distanceKm;

  const LeaderboardItem({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    required this.co2SavedKg,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('$rank')),
        title: Text(name),
        subtitle: Text(
          '${distanceKm.toStringAsFixed(1)} km • '
          '${co2SavedKg.toStringAsFixed(1)} kg CO₂ saved',
        ),
        trailing: Text(
          '$points pts',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
