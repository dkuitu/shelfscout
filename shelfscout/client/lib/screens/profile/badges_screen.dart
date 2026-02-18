import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/badge.dart' as models;
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
      appBar: AppBar(
        title: Text(
          'BADGES',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.badges.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.military_tech,
                          size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text(
                        'No badges earned yet',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submit prices and validate to earn badges!',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: provider.badges.length,
                  itemBuilder: (context, index) {
                    return _BadgeCard(badge: provider.badges[index])
                        .animate()
                        .fadeIn(delay: (index * 60).ms)
                        .scale(begin: const Offset(0.9, 0.9));
                  },
                ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final models.Badge badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isLegendary = badge.rarity == models.BadgeRarity.legendary;
    final isEpic = badge.rarity == models.BadgeRarity.epic;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _rarityColor.withAlpha(isLegendary ? 120 : 50),
          width: isLegendary || isEpic ? 2 : 1,
        ),
        boxShadow: isLegendary
            ? [
                BoxShadow(
                  color: AppTheme.goldColor.withAlpha(50),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : isEpic
                ? [
                    BoxShadow(
                      color: AppTheme.epicPurple.withAlpha(30),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
              const SizedBox(height: 10),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rajdhani(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: _rarityColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _rarityColor.withAlpha(40)),
                ),
                child: Text(
                  badge.rarity.name.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _rarityColor,
                    letterSpacing: 0.5,
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
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.military_tech, color: _rarityColor, size: 56),
              const SizedBox(height: 14),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: _rarityColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge.rarity.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _rarityColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
              if (badge.earnedAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Earned: ${badge.earnedAt!.toLocal().toString().split('.').first}',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: Colors.white30,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _rarityColor {
    switch (badge.rarity) {
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
