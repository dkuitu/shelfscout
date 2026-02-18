import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/leaderboard_entry.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadTab(_tabController.index);
      }
    });
    Future.microtask(() => _loadTab(0));
  }

  void _loadTab(int index) {
    final provider = context.read<LeaderboardProvider>();
    switch (index) {
      case 0:
        provider.loadLeaderboard('national');
        break;
      case 1:
        provider.loadLeaderboard('weekly');
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RANKS',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.conquestGreen.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.conquestGreen, width: 1),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppTheme.conquestGreen,
              unselectedLabelColor: Colors.white38,
              labelStyle: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'NATIONAL'),
                Tab(text: 'WEEKLY'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardList(
            provider: provider,
            scope: 'national',
            currentUserId: currentUserId,
          ),
          _LeaderboardList(
            provider: provider,
            scope: 'weekly',
            currentUserId: currentUserId,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final LeaderboardProvider provider;
  final String scope;
  final String? currentUserId;

  const _LeaderboardList({
    required this.provider,
    required this.scope,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.currentScope == scope) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.currentScope == scope) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppTheme.dangerRed, size: 48),
            const SizedBox(height: 12),
            Text(provider.error!, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  context.read<LeaderboardProvider>().loadLeaderboard(scope),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (provider.currentScope != scope) {
      return const Center(
        child: Text('Tap to load', style: TextStyle(color: Colors.white38)),
      );
    }
    if (provider.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.leaderboard, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              'No entries yet',
              style: GoogleFonts.rajdhani(
                  fontSize: 18, color: Colors.white38),
            ),
          ],
        ),
      );
    }

    // Find current user's entry
    final myEntry = currentUserId != null
        ? provider.entries
            .where((e) => e.userId == currentUserId)
            .firstOrNull
        : null;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Your Rank banner
        if (myEntry != null)
          _YourRankBanner(entry: myEntry)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1),

        const SizedBox(height: 8),

        // Top 3 podium
        if (provider.entries.length >= 3) ...[
          _TopThreePodium(
            entries: provider.entries.take(3).toList(),
            currentUserId: currentUserId,
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
          const SizedBox(height: 8),
        ],

        // Rest of the list
        ...provider.entries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          if (index < 3 && provider.entries.length >= 3) {
            return const SizedBox.shrink();
          }
          return _LeaderboardRow(
            entry: item,
            isCurrentUser: item.userId == currentUserId,
            scope: scope,
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (100 + index * 50).ms)
              .slideX(begin: 0.05);
        }),
      ],
    );
  }
}

class _YourRankBanner extends StatelessWidget {
  final LeaderboardEntry entry;

  const _YourRankBanner({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.conquestGreen.withAlpha(30),
            AppTheme.conquestGreen.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.conquestGreen.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.greenGradient,
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR RANK',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.conquestGreen,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.username,
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (entry.crownCount > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events,
                    color: AppTheme.goldColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${entry.crownCount}',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.goldColor,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String? currentUserId;

  const _TopThreePodium({required this.entries, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (entries.length > 1)
            Expanded(
              child: _PodiumCard(
                entry: entries[1],
                rank: 2,
                height: 110,
                isCurrentUser: entries[1].userId == currentUserId,
              ),
            ),
          const SizedBox(width: 8),
          // 1st place
          Expanded(
            child: _PodiumCard(
              entry: entries[0],
              rank: 1,
              height: 140,
              isCurrentUser: entries[0].userId == currentUserId,
            ),
          ),
          const SizedBox(width: 8),
          // 3rd place
          if (entries.length > 2)
            Expanded(
              child: _PodiumCard(
                entry: entries[2],
                rank: 3,
                height: 90,
                isCurrentUser: entries[2].userId == currentUserId,
              ),
            ),
        ],
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final bool isCurrentUser;

  const _PodiumCard({
    required this.entry,
    required this.rank,
    required this.height,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _rankColor.withAlpha(40),
            _rankColor.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? AppTheme.conquestGreen.withAlpha(150)
              : _rankColor.withAlpha(60),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_trophyIcon, color: _rankColor, size: rank == 1 ? 28 : 22),
          const SizedBox(height: 6),
          Text(
            entry.username,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events,
                  color: AppTheme.goldColor, size: 12),
              const SizedBox(width: 2),
              Text(
                '${entry.crownCount}',
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.goldColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _rankColor {
    switch (rank) {
      case 1:
        return AppTheme.goldColor;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  IconData get _trophyIcon {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.workspace_premium;
      case 3:
        return Icons.military_tech;
      default:
        return Icons.star;
    }
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final String scope;

  const _LeaderboardRow({
    required this.entry,
    this.isCurrentUser = false,
    required this.scope,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.conquestGreen.withAlpha(15)
            : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: isCurrentUser
            ? Border.all(color: AppTheme.conquestGreen.withAlpha(80))
            : Border.all(color: Colors.white.withAlpha(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 32,
              child: Text(
                '#${entry.rank}',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser
                      ? AppTheme.conquestGreen
                      : Colors.white38,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.username,
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isCurrentUser ? Colors.white : Colors.white70,
                    ),
                  ),
                  Text(
                    scope == 'weekly' && entry.verifiedSubmissions != null
                        ? '${entry.verifiedSubmissions} verified'
                        : '${entry.submissionCount} scouted',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white30,
                    ),
                  ),
                ],
              ),
            ),

            // Crown count
            if (entry.crownCount > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events,
                      color: AppTheme.goldColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.crownCount}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.goldColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
