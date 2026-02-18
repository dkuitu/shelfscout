import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/item.dart';
import '../../models/store.dart';
import '../../providers/category_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/submission_provider.dart';
import '../../services/camera_service.dart';
import '../../utils/validators.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({super.key});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _searchController = TextEditingController();
  final _cameraService = CameraService();

  Store? _selectedStore;
  Item? _selectedItem;
  String? _photoPath;
  double? _gpsLat;
  double? _gpsLng;
  bool _locationLoading = false;
  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Store && _selectedStore == null) {
      _selectedStore = args;
    }
    if (!_dataLoaded) {
      _dataLoaded = true;
      final catProvider = context.read<CategoryProvider>();
      catProvider.loadCategories();
      final itemProvider = context.read<ItemProvider>();
      itemProvider.searchItems();
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.photo_camera,
                    color: AppTheme.conquestGreen, size: 18),
                const SizedBox(width: 8),
                Text(
                  'CAPTURE EVIDENCE',
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
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white70),
            title: Text('Take Photo',
                style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text('Use camera to capture price tag',
                style: GoogleFonts.rajdhani(
                    fontSize: 12, color: Colors.white30)),
            onTap: () async {
              Navigator.pop(ctx);
              final path = await _cameraService.capturePhoto();
              if (path != null && mounted) {
                setState(() => _photoPath = path);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white70),
            title: Text('Choose from Gallery',
                style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text('Select an existing photo',
                style: GoogleFonts.rajdhani(
                    fontSize: 12, color: Colors.white30)),
            onTap: () async {
              Navigator.pop(ctx);
              final path = await _cameraService.pickFromGallery();
              if (path != null && mounted) {
                setState(() => _photoPath = path);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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
    if (_photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Photo required — capture a price tag or receipt')),
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
      photoFilePath: _photoPath!,
      gpsLat: _gpsLat!,
      gpsLng: _gpsLng!,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intel submitted successfully!')),
      );
      _priceController.clear();
      setState(() {
        _selectedItem = null;
        _photoPath = null;
      });
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
    final catProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCOUT REPORT',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.hourglass_top, color: Colors.white54),
            tooltip: 'Pending Items',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.pendingItems),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Store selector
              _buildStoreSelector(mapProvider),
              const SizedBox(height: 16),

              // Item picker with search + category chips
              _buildItemPicker(itemProvider, catProvider),
              const SizedBox(height: 16),

              // Price input
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

              // Photo capture — REQUIRED
              _buildPhotoCapture(),
              const SizedBox(height: 16),

              // GPS status
              _buildGpsStatus(),
              const SizedBox(height: 24),

              // Submit button
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

  Widget _buildStoreSelector(MapProvider mapProvider) {
    return GestureDetector(
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
    );
  }

  Widget _buildItemPicker(ItemProvider itemProvider, CategoryProvider catProvider) {
    return Container(
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
                'SELECT ITEM',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ),
              if (itemProvider.isSearching) ...[
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

          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (q) => itemProvider.searchItems(query: q),
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon:
                  const Icon(Icons.search, size: 20, color: Colors.white38),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          size: 18, color: Colors.white38),
                      onPressed: () {
                        _searchController.clear();
                        itemProvider.searchItems(query: '');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: AppTheme.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintStyle:
                  GoogleFonts.rajdhani(fontSize: 14, color: Colors.white30),
            ),
            style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 10),

          // Category chips
          if (catProvider.categories.isNotEmpty)
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(null, 'All', Icons.apps, Colors.white54,
                      itemProvider),
                  ...catProvider.categories.map((cat) => _buildCategoryChip(
                      cat.id, cat.name, cat.iconData, cat.colorValue,
                      itemProvider)),
                ],
              ),
            ),
          const SizedBox(height: 10),

          // Selected item display
          if (_selectedItem != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.conquestGreen.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.conquestGreen.withAlpha(60)),
              ),
              child: Row(
                children: [
                  Icon(_selectedItem!.catIcon,
                      size: 16, color: AppTheme.conquestGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedItem!.displayName,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.conquestGreen,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedItem = null),
                    child: const Icon(Icons.close,
                        size: 16, color: AppTheme.conquestGreen),
                  ),
                ],
              ),
            )
          else
            // Search results list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: itemProvider.searchResults.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No items found',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: itemProvider.searchResults.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (context, index) {
                        final item = itemProvider.searchResults[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(item.catIcon,
                              size: 18, color: item.catColor),
                          title: Text(
                            item.displayName,
                            style: GoogleFonts.rajdhani(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            item.categoryName ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: item.catColor.withAlpha(180),
                            ),
                          ),
                          onTap: () =>
                              setState(() => _selectedItem = item),
                        );
                      },
                    ),
            ),

          // Suggest item link
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.suggestItem),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline,
                    size: 14, color: AppTheme.goldColor),
                const SizedBox(width: 6),
                Text(
                  "Don't see your item? Suggest it",
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.goldColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? id, String label, IconData icon,
      Color color, ItemProvider itemProvider) {
    final isSelected = itemProvider.selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => itemProvider.selectCategory(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(30) : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.white12,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: isSelected ? color : Colors.white38),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCapture() {
    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _photoPath != null
                ? AppTheme.conquestGreen.withAlpha(60)
                : AppTheme.dangerRed.withAlpha(40),
          ),
        ),
        child: _photoPath != null
            ? Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_photoPath!),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          size: 14, color: AppTheme.conquestGreen),
                      const SizedBox(width: 6),
                      Text(
                        'Photo captured',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.conquestGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Text(
                          'Retake',
                          style: GoogleFonts.rajdhani(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppTheme.dangerRed.withAlpha(15),
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      color: AppTheme.dangerRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capture Price Tag / Receipt',
                          style: GoogleFonts.rajdhani(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Required for verification',
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            color: AppTheme.dangerRed.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppTheme.dangerRed.withAlpha(40)),
                    ),
                    child: Text(
                      'REQUIRED',
                      style: GoogleFonts.orbitron(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dangerRed,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGpsStatus() {
    return Container(
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
