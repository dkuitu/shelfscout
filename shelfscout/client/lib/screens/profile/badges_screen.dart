import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/badge.dart';
import '../../providers/user_provider.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().loadBadges());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.badges.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.military_tech, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No badges earned yet.'),
                      SizedBox(height: 8),
                      Text('Submit prices and validate to earn badges!',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: provider.badges.length,
                  itemBuilder: (context, index) {
                    return _BadgeCard(badge: provider.badges[index]);
                  },
                ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final Badge badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.military_tech,
                size: 48,
                color: _rarityColor,
              ),
              const SizedBox(height: 8),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _rarityColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge.rarity.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _rarityColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.military_tech, color: _rarityColor),
            const SizedBox(width: 8),
            Expanded(child: Text(badge.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description),
            const SizedBox(height: 12),
            Text(
              'Rarity: ${badge.rarity.name}',
              style: TextStyle(color: _rarityColor, fontWeight: FontWeight.bold),
            ),
            if (badge.earnedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Earned: ${badge.earnedAt!.toLocal().toString().split('.').first}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color get _rarityColor {
    switch (badge.rarity) {
      case BadgeRarity.legendary:
        return const Color(0xFFFFD600);
      case BadgeRarity.epic:
        return Colors.purple;
      case BadgeRarity.rare:
        return Colors.blue;
      case BadgeRarity.uncommon:
        return Colors.green;
      case BadgeRarity.common:
        return Colors.grey;
    }
  }
}
