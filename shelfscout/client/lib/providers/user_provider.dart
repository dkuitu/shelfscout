import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/badge.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;

  User? _profile;
  List<Badge> _badges = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  UserProvider(ApiClient api) : _userService = UserService(api);

  User? get profile => _profile;
  List<Badge> get badges => _badges;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _userService.getProfile();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load profile';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBadges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _badges = await _userService.getBadges();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load badges';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _stats = await _userService.getStats();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load stats';
      _isLoading = false;
      notifyListeners();
    }
  }
}
