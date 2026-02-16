import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/crown.dart';
import '../services/api_client.dart';
import '../services/crown_service.dart';

class CrownProvider extends ChangeNotifier {
  final CrownService _crownService;

  List<Crown> _userCrowns = [];
  List<Crown> _regionCrowns = [];
  bool _isLoading = false;
  String? _error;

  CrownProvider(ApiClient api) : _crownService = CrownService(api);

  List<Crown> get userCrowns => _userCrowns;
  List<Crown> get regionCrowns => _regionCrowns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserCrowns() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userCrowns = await _crownService.getUserCrowns();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load crowns';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRegionCrowns(String regionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _regionCrowns = await _crownService.getRegionCrowns(regionId);
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load region crowns';
      _isLoading = false;
      notifyListeners();
    }
  }
}
