import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/store.dart';
import '../services/api_client.dart';
import '../services/store_service.dart';

class MapProvider extends ChangeNotifier {
  final StoreService _storeService;

  List<Store> _stores = [];
  bool _isLoading = false;
  String? _error;
  double _currentLat = 0;
  double _currentLng = 0;

  MapProvider(ApiClient api) : _storeService = StoreService(api);

  List<Store> get stores => _stores;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;

  Future<void> loadNearbyStores(double lat, double lng) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentLat = lat;
      _currentLng = lng;
      _stores = await _storeService.getNearbyStores(lat, lng);
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load stores';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePosition(double lat, double lng) async {
    _currentLat = lat;
    _currentLng = lng;
    notifyListeners();
  }
}
