import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';
import '../services/api_client.dart';
import '../services/leaderboard_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _leaderboardService;

  List<LeaderboardEntry> _entries = [];
  bool _isLoading = false;
  String _currentScope = 'national';
  String? _error;

  LeaderboardProvider(ApiClient api)
      : _leaderboardService = LeaderboardService(api);

  List<LeaderboardEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String get currentScope => _currentScope;
  String? get error => _error;

  Future<void> loadLeaderboard(String scope, {String? regionId}) async {
    _isLoading = true;
    _error = null;
    _currentScope = scope;
    notifyListeners();
    try {
      switch (scope) {
        case 'regional':
          if (regionId != null) {
            _entries =
                await _leaderboardService.getRegionalLeaderboard(regionId);
          }
          break;
        case 'national':
          _entries = await _leaderboardService.getNationalLeaderboard();
          break;
        case 'weekly':
          _entries = await _leaderboardService.getWeeklyLeaderboard();
          break;
      }
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.message ?? 'Failed to load leaderboard';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
