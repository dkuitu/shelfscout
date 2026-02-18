import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/store.dart';
import '../screens/map/widgets/store_pin.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;
  final PinStatus status;

  const StoreCard({
    super.key,
    required this.store,
    this.onTap,
    this.status = PinStatus.unscouted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Chain logo circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _chainGradient,
                ),
                child: Center(
                  child: Text(
                    _chainInitial,
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Store info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      store.address,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _statusColor.withAlpha(80)),
                      ),
                      child: Text(
                        _statusLabel,
                        style: GoogleFonts.rajdhani(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Distance pill
              if (store.distanceMeters != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.deepNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    _formattedDistance,
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                    ),
                  ),
                ),
            ],
          ),
        ),
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

  String get _chainInitial {
    if (store.chain != null && store.chain!.isNotEmpty) {
      return store.chain![0].toUpperCase();
    }
    return store.name[0].toUpperCase();
  }

  LinearGradient get _chainGradient {
    // Color-code by chain
    final chain = (store.chain ?? '').toLowerCase();
    if (chain.contains('save') || chain.contains('walmart')) {
      return const LinearGradient(
          colors: [Color(0xFF448AFF), Color(0xFF2962FF)]);
    }
    if (chain.contains('whole') || chain.contains('organic')) {
      return const LinearGradient(
          colors: [Color(0xFF69F0AE), Color(0xFF00C853)]);
    }
    if (chain.contains('costco')) {
      return const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFD32F2F)]);
    }
    return AppTheme.greenGradient;
  }

  String get _formattedDistance {
    if (store.distanceMeters == null) return '';
    if (store.distanceMeters! < 1000) {
      return '${store.distanceMeters}m';
    }
    return '${(store.distanceMeters! / 1000).toStringAsFixed(1)}km';
  }
}
