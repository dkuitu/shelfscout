import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/store.dart';
import '../../providers/map_provider.dart';
import '../submission/submission_screen.dart';
import '../validation/validation_queue_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/store_pin.dart';
import 'widgets/store_detail_sheet.dart';
import 'widgets/store_list_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      context
          .read<MapProvider>()
          .loadNearbyStores(position.latitude, position.longitude);
    } catch (_) {
      if (!mounted) return;
      context
          .read<MapProvider>()
          .loadNearbyStores(AppConstants.defaultLat, AppConstants.defaultLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _MapTab(),
      const SubmissionScreen(),
      const ValidationQueueScreen(),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.deepNavy,
          border: Border(
            top: BorderSide(color: Colors.white10, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(
              icon: _navIcon(Icons.map_outlined, 0),
              activeIcon: _navIcon(Icons.map, 0, active: true),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Icons.radar_outlined, 1),
              activeIcon: _navIcon(Icons.radar, 1, active: true),
              label: 'Scout',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Icons.verified_outlined, 2),
              activeIcon: _navIcon(Icons.verified, 2, active: true),
              label: 'Verify',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Icons.leaderboard_outlined, 3),
              activeIcon: _navIcon(Icons.leaderboard, 3, active: true),
              label: 'Ranks',
            ),
            BottomNavigationBarItem(
              icon: _navIcon(Icons.person_outlined, 4),
              activeIcon: _navIcon(Icons.person, 4, active: true),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index, {bool active = false}) {
    if (!active) return Icon(icon);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.conquestGreen.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon),
    );
  }
}

class _MapTab extends StatefulWidget {
  const _MapTab();

  @override
  State<_MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab> {
  final MapController _mapController = MapController();

  PinStatus _mockPinStatus(int index) {
    switch (index) {
      case 0:
      case 1:
        return PinStatus.crowned;
      case 2:
      case 3:
        return PinStatus.scouted;
      case 4:
        return PinStatus.contested;
      default:
        return PinStatus.unscouted;
    }
  }

  void _onStoreTap(Store store, PinStatus status) {
    context.read<MapProvider>().selectStore(store);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StoreDetailSheet(store: store, status: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final userLat = mapProvider.currentLat;
    final userLng = mapProvider.currentLng;
    final hasLocation = userLat != 0 || userLng != 0;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: hasLocation
                  ? LatLng(userLat, userLng)
                  : LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
              initialZoom: AppConstants.defaultMapZoom,
              backgroundColor: AppTheme.deepNavy,
            ),
            children: [
              // Dark CartoDB tiles
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.shelfscout.app',
              ),

              // Store markers
              MarkerLayer(
                markers: mapProvider.stores
                    .where((s) => s.latitude != null && s.longitude != null)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final store = entry.value;
                  final status = _mockPinStatus(index);
                  return Marker(
                    point: LatLng(store.latitude!, store.longitude!),
                    width: 40,
                    height: 48,
                    child: StorePin(
                      status: status,
                      chain: store.chain,
                      onTap: () => _onStoreTap(store, status),
                    ),
                  );
                }).toList(),
              ),

              // User position blue dot
              if (hasLocation)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(userLat, userLng),
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF448AFF),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF448AFF).withAlpha(100),
                              blurRadius: 12,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top: Weekly challenge banner
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.deepNavy.withAlpha(220),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.goldColor.withAlpha(60)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(80),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        color: AppTheme.goldColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'WEEKLY CHALLENGE',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.goldColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Scout 5 stores to earn the Explorer badge',
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
            ),
          ),

          // Loading overlay
          if (mapProvider.isLoading)
            Container(
              color: AppTheme.deepNavy.withAlpha(150),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Error display
          if (mapProvider.error != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.dangerRed.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dangerRed.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.dangerRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        mapProvider.error!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white54),
                      onPressed: () {
                        final mp = context.read<MapProvider>();
                        mp.loadNearbyStores(mp.currentLat, mp.currentLng);
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Recenter button
          Positioned(
            right: 16,
            bottom: 280,
            child: FloatingActionButton.small(
              heroTag: 'recenter',
              backgroundColor: AppTheme.surfaceCard,
              onPressed: () {
                if (hasLocation) {
                  _mapController.move(
                      LatLng(userLat, userLng), AppConstants.defaultMapZoom);
                }
              },
              child: const Icon(Icons.my_location, color: Colors.white70),
            ),
          ),

          // Refresh stores button
          Positioned(
            right: 16,
            bottom: 330,
            child: FloatingActionButton.small(
              heroTag: 'refresh',
              backgroundColor: AppTheme.surfaceCard,
              onPressed: () {
                final mp = context.read<MapProvider>();
                if (mp.currentLat != 0) {
                  mp.loadNearbyStores(mp.currentLat, mp.currentLng);
                }
              },
              child: const Icon(Icons.refresh, color: Colors.white70),
            ),
          ),

          // Bottom: Draggable store list sheet
          StoreListSheet(
            stores: mapProvider.stores,
            onStoreTap: (store) {
              final index = mapProvider.stores.indexOf(store);
              _onStoreTap(store, _mockPinStatus(index));
            },
            statusForIndex: _mockPinStatus,
          ),
        ],
      ),
    );
  }
}
