import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/environment.dart';
import '../../config/theme.dart';
import '../../models/validation.dart';
import '../../providers/validation_provider.dart';

class ValidationDetailScreen extends StatelessWidget {
  const ValidationDetailScreen({super.key});

  String _buildPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return '';
    if (photoUrl.startsWith('http')) return photoUrl;
    return '${Environment.apiBaseUrl.replaceAll('/api', '')}$photoUrl';
  }

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)?.settings.arguments as ValidationItem?;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Submission')),
        body: const Center(child: Text('No submission data')),
      );
    }

    final fullPhotoUrl = _buildPhotoUrl(item.photoUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'REVIEW INTEL',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Large photo
            if (fullPhotoUrl.isNotEmpty)
              Image.network(
                fullPhotoUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: AppTheme.surfaceLight,
                  child: const Center(
                    child: Icon(Icons.broken_image,
                        size: 64, color: Colors.white24),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: AppTheme.surfaceLight,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.no_photography,
                          size: 48, color: Colors.white24),
                      const SizedBox(height: 8),
                      Text(
                        'No photo provided',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Price badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.conquestGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.conquestGreen.withAlpha(60)),
                      ),
                      child: Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.orbitron(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.conquestGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Item info
                  _buildInfoRow(
                    Icons.inventory_2,
                    'Item',
                    item.itemName ?? item.itemId,
                    AppTheme.rareBlue,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.store,
                    'Store',
                    item.storeName ?? item.storeId,
                    AppTheme.conquestGreen,
                  ),
                  if (item.categoryName != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.category,
                      'Category',
                      item.categoryName!,
                      AppTheme.goldColor,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.schedule,
                    'Submitted',
                    _formatDate(item.submittedAt),
                    Colors.white54,
                  ),
                  const SizedBox(height: 24),

                  // Confirm / Flag buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppTheme.dangerRed.withAlpha(60)),
                          ),
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _vote(context, item, ValidationVote.flag),
                            icon: const Icon(Icons.flag,
                                color: AppTheme.dangerRed, size: 20),
                            label: Text(
                              'FLAG',
                              style: GoogleFonts.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.dangerRed,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.greenGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: FilledButton.icon(
                            onPressed: () =>
                                _vote(context, item, ValidationVote.confirm),
                            icon: const Icon(Icons.check,
                                color: Colors.black87, size: 20),
                            label: Text(
                              'CONFIRM',
                              style: GoogleFonts.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(20),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  color: Colors.white30,
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.rajdhani(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _vote(
      BuildContext context, ValidationItem item, ValidationVote vote) async {
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
    if (success) Navigator.pop(context);
  }
}
