import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/store.dart';
import '../../providers/map_provider.dart';
import '../../providers/submission_provider.dart';
import '../../utils/validators.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({super.key});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemIdController = TextEditingController();
  final _priceController = TextEditingController();
  final _photoUrlController = TextEditingController();

  Store? _selectedStore;
  double? _gpsLat;
  double? _gpsLng;
  bool _locationLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Store && _selectedStore == null) {
      _selectedStore = args;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _locationLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _gpsLat = position.latitude;
        _gpsLng = position.longitude;
        _locationLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final mp = context.read<MapProvider>();
      setState(() {
        _gpsLat = mp.currentLat;
        _gpsLng = mp.currentLng;
        _locationLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _itemIdController.dispose();
    _priceController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a store')),
      );
      return;
    }
    if (_gpsLat == null || _gpsLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for GPS location...')),
      );
      return;
    }

    final provider = context.read<SubmissionProvider>();
    final success = await provider.submitPrice(
      storeId: _selectedStore!.id,
      itemId: _itemIdController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      photoUrl: _photoUrlController.text.trim(),
      gpsLat: _gpsLat!,
      gpsLng: _gpsLng!,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intel submitted successfully!')),
      );
      _priceController.clear();
      _photoUrlController.clear();
      _itemIdController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Submission failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubmissionProvider>();
    final mapProvider = context.watch<MapProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCOUT REPORT',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Store selector
              GestureDetector(
                onTap: () => _showStorePicker(context, mapProvider),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedStore != null
                          ? AppTheme.conquestGreen.withAlpha(60)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedStore != null
                              ? AppTheme.conquestGreen.withAlpha(30)
                              : AppTheme.surfaceLight,
                        ),
                        child: Icon(
                          Icons.store,
                          color: _selectedStore != null
                              ? AppTheme.conquestGreen
                              : Colors.white38,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedStore?.name ?? 'Select Target Store',
                              style: GoogleFonts.rajdhani(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _selectedStore != null
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                            if (_selectedStore != null)
                              Text(
                                _selectedStore!.address,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _itemIdController,
                decoration: InputDecoration(
                  labelText: 'Item ID',
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  hintText: 'Enter the item identifier',
                  labelStyle: GoogleFonts.rajdhani(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Item ID is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixIcon: const Icon(Icons.attach_money),
                  hintText: '0.00',
                  labelStyle: GoogleFonts.rajdhani(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.price,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _photoUrlController,
                decoration: InputDecoration(
                  labelText: 'Photo URL',
                  prefixIcon: const Icon(Icons.photo_camera_outlined),
                  hintText: 'https://example.com/photo.jpg',
                  labelStyle: GoogleFonts.rajdhani(),
                ),
                keyboardType: TextInputType.url,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Photo URL is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // GPS status indicator
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _gpsLat != null
                        ? AppTheme.conquestGreen.withAlpha(40)
                        : Colors.white12,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gpsLat != null
                            ? AppTheme.conquestGreen.withAlpha(25)
                            : AppTheme.surfaceLight,
                      ),
                      child: Icon(
                        _locationLoading
                            ? Icons.gps_not_fixed
                            : _gpsLat != null
                                ? Icons.gps_fixed
                                : Icons.gps_off,
                        size: 16,
                        color: _gpsLat != null
                            ? AppTheme.conquestGreen
                            : Colors.white38,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _locationLoading
                                ? 'Acquiring GPS lock...'
                                : _gpsLat != null
                                    ? 'GPS LOCKED'
                                    : 'GPS unavailable',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _gpsLat != null
                                  ? AppTheme.conquestGreen
                                  : Colors.white38,
                              letterSpacing: 1,
                            ),
                          ),
                          if (_gpsLat != null)
                            Text(
                              '${_gpsLat!.toStringAsFixed(4)}, ${_gpsLng!.toStringAsFixed(4)}',
                              style: GoogleFonts.rajdhani(
                                fontSize: 12,
                                color: Colors.white30,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_locationLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.greenGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.conquestGreen.withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: provider.isSubmitting ? null : _submit,
                  icon: provider.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black54,
                          ),
                        )
                      : const Icon(Icons.radar, color: Colors.black87),
                  label: Text(
                    provider.isSubmitting
                        ? 'TRANSMITTING...'
                        : 'SUBMIT INTEL',
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStorePicker(BuildContext context, MapProvider mapProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final stores = mapProvider.stores;
        if (stores.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No stores loaded. Go to Map tab first.',
                style: GoogleFonts.rajdhani(color: Colors.white54),
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.store, color: AppTheme.conquestGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'SELECT TARGET',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: stores.length,
                itemBuilder: (ctx, i) {
                  final store = stores[i];
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceLight,
                      ),
                      child: const Icon(Icons.store,
                          color: Colors.white38, size: 18),
                    ),
                    title: Text(
                      store.name,
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      store.address,
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                      ),
                    ),
                    trailing: store.distanceMeters != null
                        ? Text(
                            '${store.distanceMeters}m',
                            style: GoogleFonts.rajdhani(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedStore = store);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
