import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/validation.dart';
import '../../providers/validation_provider.dart';

class ValidationQueueScreen extends StatefulWidget {
  const ValidationQueueScreen({super.key});

  @override
  State<ValidationQueueScreen> createState() => _ValidationQueueScreenState();
}

class _ValidationQueueScreenState extends State<ValidationQueueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ValidationProvider>().loadQueue());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ValidationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VERIFY INTEL',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: () => context.read<ValidationProvider>().loadQueue(),
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
                        context.read<ValidationProvider>().loadQueue(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (provider.queue.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified,
                      size: 64, color: AppTheme.conquestGreen),
                  const SizedBox(height: 16),
                  Text(
                    'All clear, scout!',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No intel to verify right now.\nCheck back later!',
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
            itemCount: provider.queue.length,
            itemBuilder: (context, index) {
              return _ValidationCard(item: provider.queue[index])
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

class _ValidationCard extends StatelessWidget {
  final ValidationItem item;

  const _ValidationCard({required this.item});

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
                    color: AppTheme.rareBlue.withAlpha(25),
                  ),
                  child: const Icon(Icons.inventory_2,
                      size: 18, color: AppTheme.rareBlue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item: ${item.itemId}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Store: ${item.storeId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.conquestGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.conquestGreen.withAlpha(40)),
                  ),
                  child: Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.conquestGreen,
                    ),
                  ),
                ),
              ],
            ),
            if (item.photoUrl != null && item.photoUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.photoUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child:
                          Icon(Icons.broken_image, size: 48, color: Colors.white24),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dangerRed.withAlpha(60)),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () => _vote(context, ValidationVote.flag),
                      icon: const Icon(Icons.flag,
                          color: AppTheme.dangerRed, size: 18),
                      label: Text(
                        'FLAG',
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
                      onPressed: () => _vote(context, ValidationVote.confirm),
                      icon: const Icon(Icons.check,
                          color: Colors.black87, size: 18),
                      label: Text(
                        'CONFIRM',
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

  Future<void> _vote(BuildContext context, ValidationVote vote) async {
    final provider = context.read<ValidationProvider>();
    final success = await provider.submitVote(item.id, vote);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? (vote == ValidationVote.confirm
                ? 'Intel confirmed!'
                : 'Intel flagged!')
            : (provider.error ?? 'Vote failed')),
      ),
    );
  }
}
