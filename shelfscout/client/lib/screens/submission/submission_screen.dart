import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/item.dart';
import '../../models/store.dart';
import '../../providers/item_provider.dart';
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
  final _priceController = TextEditingController();

  Store? _selectedStore;
  Item? _selectedItem;
  double? _gpsLat;
  double? _gpsLng;
  bool _locationLoading = false;
  bool _itemsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Store && _selectedStore == null) {
      _selectedStore = args;
    }
    if (!_itemsLoaded) {
      _itemsLoaded = true;
      final itemProvider = context.read<ItemProvider>();
      if (itemProvider.weeklyItems.isEmpty) {
        itemProvider.loadWeeklyItems();
      }
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
    _priceController.dispose();
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
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item')),
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
      itemId: _selectedItem!.id,
      price: double.parse(_priceController.text.trim()),
      gpsLat: _gpsLat!,
      gpsLng: _gpsLng!,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intel submitted successfully!')),
      );
      _priceController.clear();
      setState(() => _selectedItem = null);
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
    final itemProvider = context.watch<ItemProvider>();

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

              // Weekly item picker
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedItem != null
                        ? AppTheme.conquestGreen.withAlpha(60)
                        : Colors.white12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedItem != null
                                ? AppTheme.conquestGreen.withAlpha(25)
                                : AppTheme.surfaceLight,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: _selectedItem != null
                                ? AppTheme.conquestGreen
                                : Colors.white38,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'WEEKLY ITEMS',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                            letterSpacing: 1,
                          ),
                        ),
                        if (itemProvider.isLoading) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (itemProvider.weeklyItems.isEmpty &&
                        !itemProvider.isLoading)
                      Text(
                        'No items available this week',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      )
                    else
                      _buildItemChips(itemProvider.weeklyItems),
                  ],
                ),
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

              // Optional photo area
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppTheme.surfaceLight,
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white24,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Photo',
                            style: GoogleFonts.rajdhani(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white54,
                            ),
                          ),
                          Text(
                            'Optional - camera coming soon',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        'OPTIONAL',
                        style: GoogleFonts.orbitron(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Colors.white30,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildItemChips(List<Item> items) {
    // Group items by category
    final categories = <String, List<Item>>{};
    for (final item in items) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = _selectedItem?.id == item.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedItem = item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.conquestGreen.withAlpha(30)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.conquestGreen
                    : Colors.white12,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _categoryIcon(item.category),
                  size: 14,
                  color: isSelected
                      ? AppTheme.conquestGreen
                      : _categoryColor(item.category),
                ),
                const SizedBox(width: 6),
                Text(
                  item.displayName,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppTheme.conquestGreen : Colors.white70,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: AppTheme.conquestGreen,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return Icons.water_drop;
      case 'bakery':
      case 'bread':
        return Icons.bakery_dining;
      case 'produce':
      case 'fruit':
      case 'vegetable':
        return Icons.eco;
      case 'meat':
      case 'protein':
        return Icons.restaurant;
      case 'beverage':
      case 'drink':
        return Icons.local_cafe;
      case 'snack':
      case 'snacks':
        return Icons.cookie;
      default:
        return Icons.shopping_basket;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return const Color(0xFF64B5F6);
      case 'bakery':
      case 'bread':
        return const Color(0xFFFFB74D);
      case 'produce':
      case 'fruit':
      case 'vegetable':
        return const Color(0xFF81C784);
      case 'meat':
      case 'protein':
        return const Color(0xFFE57373);
      case 'beverage':
      case 'drink':
        return const Color(0xFF4DD0E1);
      case 'snack':
      case 'snacks':
        return const Color(0xFFFFF176);
      default:
        return Colors.white54;
    }
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
                  const Icon(Icons.store,
                      color: AppTheme.conquestGreen, size: 18),
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
