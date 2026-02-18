import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/badge.dart' as models;
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

    final trustScore = profile?.trustScore ?? 50.0;
    final level = _getLevel(trustScore);
    final levelProgress = _getLevelProgress(trustScore);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
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
                  // Profile header with level
                  _ProfileHeader(
                    username: profile?.username ?? 'Unknown',
                    email: profile?.email ?? '',
                    trustScore: trustScore,
                    level: level,
                    levelProgress: levelProgress,
                    regionName: profile?.regionName,
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),

                  // Stats grid
                  _buildStatsGrid(context, userProvider.stats, crownProvider)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 24),

                  // Crown collection
                  if (crownProvider.userCrowns.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'CROWN COLLECTION',
                      icon: Icons.emoji_events,
                      iconColor: AppTheme.goldColor,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: crownProvider.userCrowns.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final crown = crownProvider.userCrowns[i];
                          return Container(
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.goldColor.withAlpha(25),
                                  AppTheme.goldColor.withAlpha(8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppTheme.goldColor.withAlpha(50)),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.emoji_events,
                                    color: AppTheme.goldColor, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  crown.itemName ?? crown.itemId,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (i * 80).ms)
                              .slideX(begin: 0.1);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Badges section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionHeader(
                        title: 'BADGES',
                        icon: Icons.military_tech,
                        iconColor: AppTheme.epicPurple,
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.badges),
                        child: Text(
                          'View All',
                          style: GoogleFonts.rajdhani(
                            color: AppTheme.conquestGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (userProvider.badges.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.military_tech,
                              size: 40, color: Colors.white24),
                          const SizedBox(height: 8),
                          Text(
                            'No badges earned yet',
                            style: GoogleFonts.rajdhani(
                                fontSize: 16, color: Colors.white38),
                          ),
                          Text(
                            'Keep scouting to earn your first badge!',
                            style: GoogleFonts.rajdhani(
                                fontSize: 13, color: Colors.white24),
                          ),
                        ],
                      ),
                    )
                  else
                    _BadgeGrid(badges: userProvider.badges),
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
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: [
        _StatCard(
          icon: Icons.emoji_events,
          label: 'Crowns',
          value: '$activeCrowns',
          color: AppTheme.goldColor,
        ),
        _StatCard(
          icon: Icons.radar,
          label: 'Scouted',
          value: '${submissions['total'] ?? 0}',
          color: AppTheme.conquestGreen,
        ),
        _StatCard(
          icon: Icons.verified,
          label: 'Verified',
          value: '${validations['total'] ?? 0}',
          color: AppTheme.rareBlue,
        ),
        _StatCard(
          icon: Icons.military_tech,
          label: 'Badges',
          value: '$badgesEarned',
          color: AppTheme.epicPurple,
        ),
      ],
    );
  }

  String _getLevel(double trustScore) {
    if (trustScore >= 95) return 'Legendary Scout';
    if (trustScore >= 85) return 'Master Scout';
    if (trustScore >= 75) return 'Elite Scout';
    if (trustScore >= 65) return 'Veteran Scout';
    if (trustScore >= 55) return 'Field Scout';
    if (trustScore >= 45) return 'Scout';
    return 'Rookie Scout';
  }

  double _getLevelProgress(double trustScore) {
    // Progress within current 10-point tier
    final tier = (trustScore / 10).floor() * 10;
    return (trustScore - tier) / 10;
  }
}

class _ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final double trustScore;
  final String level;
  final double levelProgress;
  final String? regionName;

  const _ProfileHeader({
    required this.username,
    required this.email,
    required this.trustScore,
    required this.level,
    required this.levelProgress,
    this.regionName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.greenGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.conquestGreen.withAlpha(60),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                username[0].toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Username
          Text(
            username,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 14),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.conquestGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppTheme.conquestGreen.withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield,
                    size: 16, color: AppTheme.conquestGreen),
                const SizedBox(width: 6),
                Text(
                  level.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.conquestGreen,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // XP progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trust Score',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                  Text(
                    '${trustScore.toStringAsFixed(1)} / 100',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.conquestGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: trustScore / 100,
                  minHeight: 8,
                  backgroundColor: AppTheme.deepNavy,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.conquestGreen),
                ),
              ),
            ],
          ),

          if (regionName != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on,
                    size: 14, color: Colors.white30),
                const SizedBox(width: 4),
                Text(
                  regionName!,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white54,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  final List<models.Badge> badges;

  const _BadgeGrid({required this.badges});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length > 6 ? 6 : badges.length,
      itemBuilder: (context, i) {
        final badge = badges[i];
        final rarityColor = _rarityColor(badge.rarity);
        final isLegendary = badge.rarity == models.BadgeRarity.legendary;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: rarityColor.withAlpha(60)),
            boxShadow: isLegendary
                ? [
                    BoxShadow(
                      color: AppTheme.goldColor.withAlpha(40),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.military_tech,
                size: 32,
                color: rarityColor,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: rarityColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge.rarity.name.toUpperCase(),
                  style: GoogleFonts.rajdhani(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: rarityColor,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (i * 60).ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }

  Color _rarityColor(models.BadgeRarity rarity) {
    switch (rarity) {
      case models.BadgeRarity.legendary:
        return AppTheme.legendaryGold;
      case models.BadgeRarity.epic:
        return AppTheme.epicPurple;
      case models.BadgeRarity.rare:
        return AppTheme.rareBlue;
      case models.BadgeRarity.uncommon:
        return AppTheme.uncommonGreen;
      case models.BadgeRarity.common:
        return Colors.grey;
    }
  }
}
