import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/map_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../submission/submission_screen.dart';
import '../validation/validation_queue_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';

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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      context
          .read<MapProvider>()
          .loadNearbyStores(position.latitude, position.longitude);
    } catch (_) {
      if (!mounted) return;
      // Fall back to Vancouver defaults
      context
          .read<MapProvider>()
          .loadNearbyStores(AppConstants.defaultLat, AppConstants.defaultLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _StoresTab(),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Stores'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Submit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline), label: 'Validate'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Ranks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _StoresTab extends StatelessWidget {
  const _StoresTab();

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShelfScout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final mp = context.read<MapProvider>();
              if (mp.currentLat != 0) {
                mp.loadNearbyStores(mp.currentLat, mp.currentLng);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (mapProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (mapProvider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mapProvider.error!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      final mp = context.read<MapProvider>();
                      mp.loadNearbyStores(mp.currentLat, mp.currentLng);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (mapProvider.stores.isEmpty) {
            return const Center(
              child: Text('No stores found nearby.\nTry a different location.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () {
              final mp = context.read<MapProvider>();
              return mp.loadNearbyStores(mp.currentLat, mp.currentLng);
            },
            child: ListView.builder(
              itemCount: mapProvider.stores.length,
              itemBuilder: (context, index) {
                final store = mapProvider.stores[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.store),
                  ),
                  title: Text(store.name),
                  subtitle: Text(store.address),
                  trailing: store.distanceMeters != null
                      ? Text(
                          store.distanceMeters! < 1000
                              ? '${store.distanceMeters}m'
                              : '${(store.distanceMeters! / 1000).toStringAsFixed(1)}km',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.submission,
                      arguments: store,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
