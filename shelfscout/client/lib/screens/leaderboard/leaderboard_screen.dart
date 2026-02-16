import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../config/theme.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'National'),
            Tab(text: 'Weekly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardList(provider: provider, scope: 'national'),
          _LeaderboardList(provider: provider, scope: 'weekly'),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final LeaderboardProvider provider;
  final String scope;

  const _LeaderboardList({required this.provider, required this.scope});

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
            Text(provider.error!),
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
      return const Center(child: Text('Tap to load'));
    }
    if (provider.entries.isEmpty) {
      return const Center(child: Text('No entries yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.entries.length,
      itemBuilder: (context, index) {
        final entry = provider.entries[index];
        final isTop3 = entry.rank <= 3;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: isTop3
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _rankColor(entry.rank),
                    width: 2,
                  ),
                )
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isTop3 ? _rankColor(entry.rank) : Colors.grey[300],
              foregroundColor: isTop3 ? Colors.white : Colors.black87,
              child: Text(
                '${entry.rank}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              entry.username,
              style: isTop3
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
            subtitle: scope == 'weekly' && entry.verifiedSubmissions != null
                ? Text('${entry.verifiedSubmissions} verified submissions')
                : Text('${entry.submissionCount} submissions'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entry.crownCount > 0) ...[
                  Icon(Icons.emoji_events,
                      color: AppTheme.goldColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.crownCount}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD600);
      case 2:
        return Colors.grey;
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }
}
