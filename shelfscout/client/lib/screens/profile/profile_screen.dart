import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/crown_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = context.read<UserProvider>();
      userProvider.loadProfile();
      userProvider.loadStats();
      userProvider.loadBadges();
      context.read<CrownProvider>().loadUserCrowns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final crownProvider = context.watch<CrownProvider>();
    final profile = userProvider.profile ?? auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  userProvider.loadProfile(),
                  userProvider.loadStats(),
                  userProvider.loadBadges(),
                  crownProvider.loadUserCrowns(),
                ]);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: Text(
                              (profile?.username ?? '?')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile?.username ?? 'Unknown',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            avatar: const Icon(Icons.shield, size: 18),
                            label: Text(
                              'Trust: ${profile?.trustScore.toStringAsFixed(1) ?? '50.0'}',
                            ),
                          ),
                          if (profile?.regionName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Chip(
                                avatar: const Icon(Icons.location_on, size: 18),
                                label: Text(profile!.regionName!),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Text('Stats',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildStatsGrid(context, userProvider.stats, crownProvider),
                  const SizedBox(height: 24),

                  // Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Badges',
                          style: Theme.of(context).textTheme.titleMedium),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.badges);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (userProvider.badges.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No badges earned yet. Keep scouting!'),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: userProvider.badges.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final badge = userProvider.badges[i];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.military_tech,
                                    color: _badgeColor(badge.rarity.name),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    badge.name,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats,
      CrownProvider crownProvider) {
    final activeCrowns = stats['active_crowns'] ?? 0;
    final submissions = stats['submissions'] as Map<String, dynamic>? ?? {};
    final validations = stats['validations'] as Map<String, dynamic>? ?? {};
    final badgesEarned = stats['badges_earned'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.8,
      children: [
        _StatCard(
          icon: Icons.emoji_events,
          label: 'Crowns',
          value: '$activeCrowns',
          color: const Color(0xFFFFD600),
        ),
        _StatCard(
          icon: Icons.upload,
          label: 'Submissions',
          value: '${submissions['total'] ?? 0}',
          color: Colors.blue,
        ),
        _StatCard(
          icon: Icons.check_circle,
          label: 'Validations',
          value: '${validations['total'] ?? 0}',
          color: Colors.green,
        ),
        _StatCard(
          icon: Icons.military_tech,
          label: 'Badges',
          value: '$badgesEarned',
          color: Colors.purple,
        ),
      ],
    );
  }

  Color _badgeColor(String rarity) {
    switch (rarity) {
      case 'legendary':
        return const Color(0xFFFFD600);
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      case 'uncommon':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
