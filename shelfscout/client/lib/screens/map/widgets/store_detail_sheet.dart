import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../models/store.dart';
import 'store_pin.dart';

class StoreDetailSheet extends StatelessWidget {
  final Store store;
  final PinStatus status;

  const StoreDetailSheet({
    super.key,
    required this.store,
    this.status = PinStatus.unscouted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Store header
          Row(
            children: [
              // Chain logo circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.greenGradient,
                ),
                child: Center(
                  child: Text(
                    _chainInitial,
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
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
                      store.name,
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      store.address,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (store.distanceMeters != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.deepNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    _formattedDistance,
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Status chips
          Row(
            children: [
              _StatusChip(
                icon: _statusIcon,
                label: _statusLabel,
                color: _statusColor,
              ),
              const SizedBox(width: 8),
              if (store.chain != null)
                _StatusChip(
                  icon: Icons.storefront,
                  label: store.chain!.toUpperCase(),
                  color: AppTheme.conquestGreen,
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Action button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.greenGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.submission,
                    arguments: store,
                  );
                },
                icon: const Icon(Icons.radar, color: Colors.black87),
                label: Text(
                  'SCOUT THIS STORE',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _statusLabel {
    switch (status) {
      case PinStatus.crowned:
        return 'CROWNED';
      case PinStatus.scouted:
        return 'SCOUTED';
      case PinStatus.contested:
        return 'CONTESTED';
      case PinStatus.unscouted:
        return 'UNCLAIMED';
    }
  }

  Color get _statusColor {
    switch (status) {
      case PinStatus.crowned:
        return AppTheme.goldColor;
      case PinStatus.scouted:
        return AppTheme.conquestGreen;
      case PinStatus.contested:
        return AppTheme.dangerRed;
      case PinStatus.unscouted:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case PinStatus.crowned:
        return Icons.emoji_events;
      case PinStatus.scouted:
        return Icons.check_circle;
      case PinStatus.contested:
        return Icons.bolt;
      case PinStatus.unscouted:
        return Icons.explore_off;
    }
  }

  String get _chainInitial {
    if (store.chain != null && store.chain!.isNotEmpty) {
      return store.chain![0].toUpperCase();
    }
    return store.name[0].toUpperCase();
  }

  String get _formattedDistance {
    if (store.distanceMeters == null) return '';
    if (store.distanceMeters! < 1000) {
      return '${store.distanceMeters}m';
    }
    return '${(store.distanceMeters! / 1000).toStringAsFixed(1)}km';
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
