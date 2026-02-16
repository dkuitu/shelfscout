import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
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
    // Check if store was passed as argument
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _gpsLat = position.latitude;
        _gpsLng = position.longitude;
        _locationLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Use MapProvider position as fallback
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
        const SnackBar(content: Text('Price submitted successfully!')),
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
      appBar: AppBar(title: const Text('Submit Price')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Store selector
              Card(
                child: ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(_selectedStore?.name ?? 'Select a store'),
                  subtitle: _selectedStore != null
                      ? Text(_selectedStore!.address)
                      : const Text('Tap to choose from nearby stores'),
                  onTap: () => _showStorePicker(context, mapProvider),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _itemIdController,
                decoration: const InputDecoration(
                  labelText: 'Item ID',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'Enter the item identifier',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Item ID is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  hintText: '0.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.price,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Photo URL',
                  prefixIcon: Icon(Icons.photo_camera_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/photo.jpg',
                ),
                keyboardType: TextInputType.url,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Photo URL is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // GPS info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.gps_fixed, size: 20),
                      const SizedBox(width: 8),
                      if (_locationLoading)
                        const Text('Getting location...')
                      else if (_gpsLat != null)
                        Text(
                          '${_gpsLat!.toStringAsFixed(4)}, ${_gpsLng!.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        const Text('Location unavailable'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: provider.isSubmitting ? null : _submit,
                icon: provider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(provider.isSubmitting ? 'Submitting...' : 'Submit Price'),
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
      builder: (ctx) {
        final stores = mapProvider.stores;
        if (stores.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No stores loaded. Go to Stores tab first.')),
          );
        }
        return ListView.builder(
          itemCount: stores.length,
          itemBuilder: (ctx, i) {
            final store = stores[i];
            return ListTile(
              title: Text(store.name),
              subtitle: Text(store.address),
              trailing: store.distanceMeters != null
                  ? Text('${store.distanceMeters}m')
                  : null,
              onTap: () {
                setState(() => _selectedStore = store);
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }
}
