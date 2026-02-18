import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/item.dart';
import '../../providers/item_provider.dart';

class PendingItemsScreen extends StatefulWidget {
  const PendingItemsScreen({super.key});

  @override
  State<PendingItemsScreen> createState() => _PendingItemsScreenState();
}

class _PendingItemsScreenState extends State<PendingItemsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ItemProvider>().loadPendingItems());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PENDING ITEMS',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: () => context.read<ItemProvider>().loadPendingItems(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.dangerRed, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<ItemProvider>().loadPendingItems(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (provider.pendingItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 64, color: AppTheme.conquestGreen),
                  const SizedBox(height: 16),
                  Text(
                    'No pending items',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All community suggestions have\nbeen reviewed!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: Colors.white30,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.pendingItems.length,
            itemBuilder: (context, index) {
              return _PendingItemCard(item: provider.pendingItems[index])
                  .animate()
                  .fadeIn(delay: (index * 80).ms)
                  .slideX(begin: 0.05);
            },
          );
        },
      ),
    );
  }
}

class _PendingItemCard extends StatelessWidget {
  final Item item;

  const _PendingItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.catColor.withAlpha(25),
                  ),
                  child: Icon(item.catIcon,
                      size: 18, color: item.catColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        item.categoryName ?? 'Uncategorized',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.catColor.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppTheme.goldColor.withAlpha(40)),
                  ),
                  child: Text(
                    'PENDING',
                    style: GoogleFonts.orbitron(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.goldColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.dangerRed.withAlpha(60)),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () => _vote(context, 'reject'),
                      icon: const Icon(Icons.thumb_down,
                          color: AppTheme.dangerRed, size: 18),
                      label: Text(
                        'REJECT',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.dangerRed,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.greenGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FilledButton.icon(
                      onPressed: () => _vote(context, 'approve'),
                      icon: const Icon(Icons.thumb_up,
                          color: Colors.black87, size: 18),
                      label: Text(
                        'APPROVE',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _vote(BuildContext context, String vote) async {
    final provider = context.read<ItemProvider>();
    final success = await provider.voteOnItem(item.id, vote);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? (vote == 'approve'
                ? 'Item approved!'
                : 'Item rejected.')
            : (provider.error ?? 'Vote failed')),
      ),
    );
  }
}
