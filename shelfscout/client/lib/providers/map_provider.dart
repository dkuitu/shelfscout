import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/crown.dart';
import '../models/item.dart';
import '../models/store.dart';
import '../screens/map/widgets/store_pin.dart';
import '../services/api_client.dart';
import '../services/crown_service.dart';
import '../services/item_service.dart';
import '../services/store_service.dart';

enum StoreFilter { all, crowned, scouted, unscouted }

class MapProvider extends ChangeNotifier {
  final StoreService _storeService;
  final CrownService _crownService;
  final ItemService _itemService;

  List<Store> _stores = [];
  List<Crown> _crowns = [];
  List<Item> _weeklyItems = [];
  Item? _selectedItem;
  bool _isLoading = false;
  String? _error;
  double _currentLat = 0;
  double _currentLng = 0;
  Store? _selectedStore;
  StoreFilter _filter = StoreFilter.all;

  MapProvider(ApiClient api)
      : _storeService = StoreService(api),
        _crownService = CrownService(api),
        _itemService = ItemService(api);

  List<Store> get stores => _stores;
  List<Crown> get crowns => _crowns;
  List<Item> get weeklyItems => _weeklyItems;
  Item? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;
  Store? get selectedStore => _selectedStore;
  StoreFilter get filter => _filter;

  List<Store> get filteredStores {
    return _stores;
  }

  Future<void> loadNearbyStores(double lat, double lng) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentLat = lat;
      _currentLng = lng;
      _stores = await _storeService.getNearbyStores(lat, lng);

      // After loading stores, load crowns for the region and weekly items
      if (_stores.isNotEmpty && _stores.first.regionId != null) {
        _loadCrownsForRegion(_stores.first.regionId!);
      }
      _loadWeeklyItems();

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load stores';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCrownsForRegion(String regionId) async {
    try {
      _crowns = await _crownService.getRegionCrowns(regionId);
      notifyListeners();
    } catch (_) {
      // Non-critical — keep existing crowns
    }
  }

  Future<void> _loadWeeklyItems() async {
    try {
      _weeklyItems = await _itemService.getWeeklyItems();
      notifyListeners();
    } catch (_) {
      // Non-critical
    }
  }

  PinStatus pinStatusForStore(String storeId) {
    if (_selectedItem == null) {
      return PinStatus.unscouted;
    }

    // Find crown matching (selectedItem, storeId)
    final matchingCrown = _crowns.where((c) =>
        c.itemId == _selectedItem!.id && c.storeId == storeId).firstOrNull;

    if (matchingCrown != null) {
      if (matchingCrown.status == CrownStatus.active) {
        return PinStatus.crowned;
      }
      if (matchingCrown.status == CrownStatus.contested) {
        return PinStatus.contested;
      }
    }

    // Check if there's any crown for this item at this store (scouted)
    // A store is "scouted" if any crown references it for this item
    // Since crowns are per (item, region, cycle), if the crown holder store
    // is not this store but this store has submissions, it's scouted
    // For now, if no crown match, return unscouted
    return PinStatus.unscouted;
  }

  void selectItem(Item? item) {
    _selectedItem = item;
    notifyListeners();
  }

  Future<void> updatePosition(double lat, double lng) async {
    _currentLat = lat;
    _currentLng = lng;
    notifyListeners();
  }

  void selectStore(Store? store) {
    _selectedStore = store;
    notifyListeners();
  }

  void setFilter(StoreFilter filter) {
    _filter = filter;
    notifyListeners();
  }
}
