import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../models/store.dart';
import '../../../widgets/store_card.dart';
import 'store_pin.dart';

class StoreListSheet extends StatelessWidget {
  final List<Store> stores;
  final void Function(Store store) onStoreTap;
  final PinStatus Function(int index)? statusForIndex;

  const StoreListSheet({
    super.key,
    required this.stores,
    required this.onStoreTap,
    this.statusForIndex,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.08,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [0.08, 0.3, 0.75],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.deepNavy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle + title
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(Icons.radar,
                                color: AppTheme.conquestGreen, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'NEARBY BATTLEGROUNDS',
                              style: GoogleFonts.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.conquestGreen.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${stores.length}',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.conquestGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // Store list
              Expanded(
                child: stores.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.explore_off,
                                size: 48, color: Colors.white24),
                            const SizedBox(height: 12),
                            Text(
                              'No stores in range',
                              style: GoogleFonts.rajdhani(
                                fontSize: 16,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        itemCount: stores.length,
                        itemBuilder: (context, index) {
                          final store = stores[index];
                          return StoreCard(
                            store: store,
                            status: statusForIndex?.call(index) ?? PinStatus.unscouted,
                            onTap: () => onStoreTap(store),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
