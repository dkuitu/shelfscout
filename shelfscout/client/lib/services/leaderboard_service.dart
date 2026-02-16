import '../models/leaderboard_entry.dart';
import 'api_client.dart';

class LeaderboardService {
  final ApiClient _api;

  LeaderboardService(this._api);

  Future<List<LeaderboardEntry>> getRegionalLeaderboard(
      String regionId) async {
    final res = await _api.get('/leaderboards/regional/$regionId');
    return _parseList(res.data);
  }

  Future<List<LeaderboardEntry>> getNationalLeaderboard() async {
    final res = await _api.get('/leaderboards/national');
    return _parseList(res.data);
  }

  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    final res = await _api.get('/leaderboards/weekly');
    return _parseList(res.data);
  }

  List<LeaderboardEntry> _parseList(dynamic responseData) {
    final data = responseData as Map<String, dynamic>;
    final list = data['leaderboard'] as List<dynamic>;
    return list.asMap().entries.map((e) {
      return LeaderboardEntry.fromJson(
          e.value as Map<String, dynamic>, e.key);
    }).toList();
  }
}
